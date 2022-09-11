# Port for rpcapd, must be equal to p-cap-port in config.yml
$Port = 9393

$CurrentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if ($CurrentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  $CurrentPath = Split-Path -Path (Get-Location) -Leaf
  if ($CurrentPath = "la-dpsmeter") {
    Set-Location ..
  }

  # Clone the repo
  git clone -b standalone https://github.com/guy0090/la-dpsmeter.git
  Set-Location ./la-dpsmeter

  # Get rpcapd service
  $Service = Get-Service -Name rpcapd

  # Stop rpcapd if it's already running
  Set-Service -InputObject $Service -Status Stopped

  # Set the startup path; Adds port and allows null authentication
  Set-ItemProperty -path HKLM:\SYSTEM\CurrentControlSet\Services\rpcapd -Name 'ImagePath' -value "C:\Program Files (x86)\WinPcap\rpcapd.exe -d -p $Port -n"

  # Start rpcapd and set it to auto-start
  Set-Service -InputObject $Service -StartupType Automatic -Status Running -PassThru

  # Install the container
  docker-compose -p loadps up --build -d
  docker-compose -p loadps stop

  Write-Host ""
  Write-Host "All services are now setup. Bye!"
} else {
  Write-Host 'You must run this script as administrator.';
}