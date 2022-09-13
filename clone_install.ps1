# Port for rpcapd, must be equal to p-cap-port in config.yml
$Port = 9393

# Dir to save rpcapd service
$RpcapdDir = "C:\Program Files\rpcapd"

# URL to latest libpcap release with rpcapd
$LibpcapRelease = "https://github.com/guy0090/libpcap/releases/latest/download/Build.zip"

$CurrentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if ($CurrentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  $CurrentPath = Split-Path -Path (Get-Location) -Leaf
  if ($CurrentPath -eq "la-dpsmeter") {
    Set-Location ..
  }

  # Clone the repo
  git clone -b standalone https://github.com/guy0090/la-dpsmeter.git
  Set-Location ./la-dpsmeter

  # Setup rpcapd service
  # TODO: Check for WinPcap install and cancel if present
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

    # Start rpcapd
    Start-Service rpcapd

    Write-Host "`nrpcapd service installed and started`n"
  } else {
    Write-Host "`nrpcapd service found, starting it...`n"
    Start-Service -Name rpcapd
  }

  # Install the container
  docker-compose -p loadps up --build -d
  docker-compose -p loadps stop

  Write-Host "`nAll services are now setup. Bye!"
} else {
  Write-Host 'You must run this script as administrator.';
}