# Port for rpcapd, must be equal to p-cap-port in config.yml
$Port = 9393

# Dir to save rpcapd service
$RpcapdDir = "C:\Program Files\rpcapd"

# URL to latest libpcap release with rpcapd
$LibpcapRelease = "https://github.com/guy0090/libpcap/releases/latest/download/Build.zip"

# Only allow execution from root repo dir
$CurrentPath = Split-Path -Path (Get-Location) -Leaf
if ($CurrentPath -ne "la-dpsmeter") {
  Write-Host "Please run this script from the root of the repository" -ForegroundColor Red
  Exit
}

# Check if user has admin access
$CurrentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if ($CurrentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  # Grab most recent commit
  git pull

  # Get rpcapd service
  $Service = Get-Service -Name rpcapd -ErrorAction SilentlyContinue
  if ($null -eq $Service) {
    Write-Host "`nNo rpcapd service found, downloading and installing it to $RpcapdDir"
    # If rpcapd isn't present, download and install it as a service

    # Grab latest libpcap release
    Invoke-WebRequest -Uri $LibpcapRelease -OutFile Build.zip
    Expand-Archive -Path Build.zip -DestinationPath .\Build
    Set-Location .\Build

    # Create and copy to rpcapd dir
    New-Item -ItemType Directory -Force -Path $RpcapdDir
    Copy-Item -Path .\pcap.dll -Destination $RpcapdDir
    Copy-Item -Path .\rpcapd.exe -Destination $RpcapdDir

    # Install rpcapd as a service
    New-Service -Name rpcapd -Description "Remote Packet Capture Protocol v.0 (experimental)" -BinaryPathName "$RpcapdDir\rpcapd.exe -d -p $Port -n" -StartupType Automatic

    # Cleanup build files
    Set-Location ..
    Remove-Item -Path .\Build -Recurse -Force

    # Start rpcapd service
    Start-Service -Name rpcapd

    Write-Host "`nrpcapd service installed and started"
  } elseif ($Service.Status -ne "Running") {
    # Check if rpcapd is running and start it if it isn't
    # Not going to attempt to update it, should only rarely be needed
    Write-Host "`nStarting rpcapd service"
    Start-Service -Name rpcapd
  }

  # Stop container
  docker-compose -p loadps stop

  # Rebuild container
  docker-compose -p loadps up --build -d

  Write-Host "`nServices are now updated. Bye!" -ForegroundColor Green;
} else {
  Write-Host "You must run this script as administrator." -ForegroundColor Red;
}