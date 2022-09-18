# Lost Ark Logger (Remote Version)

A fork of [https://github.com/rexlManu/la-dpsmeter](https://github.com/rexlManu/la-dpsmeter) with the capability to remote log packets to any HTTP server via Npcap for Docker.  

This branch adds HttpBridge functionality from the [main logger](https://github.com/shalzuth/LostArkLogger) to allow easy integration with LOA Details or any other app that depends on an HTTP server based listener.  

A UI is not included and packets must be processed by an external UI such as [LOA Details](https://github.com/karaeren/loa-details).  

---
## Disclaimer
This branch is generally aimed at being ran as a docker container on the **same PC** as the game. It will also work on remote setups but this currently isn't covered in this write-up.

# Logger Setup (Windows)

## Dependencies

This setup requires the following dependencies:  
*If you have them installed already, you can skip to [this section](#automatic-install).*
- Install [Npcap](https://npcap.com/dist/npcap-1.71.exe)
  - If you have WinPcap installed you may need to uninstall it.
- Install [Docker (Desktop)](https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe)
  - This [guide](https://docs.docker.com/desktop/install/windows-install/) from Docker should help if you get stuck
- Install [git](https://github.com/git-for-windows/git/releases/download/v2.37.3.windows.1/Git-2.37.3-64-bit.exe)

## Install

### Automatic Install
Once you have all dependencies installed, you can run the provided [PowerShell script](https://github.com/guy0090/la-dpsmeter/blob/standalone/clone_install.ps1).  

This script will setup the docker container for the logger service and install the `rpcapd` service to start automatically on a default port of `9393` with **null authentication enabled**. The `rpcapd` service is downloaded from a [fork of libpcap](https://github.com/guy0090/libpcap).  

### Download Script
```PowerShell
Invoke-WebRequest -Uri https://raw.githubusercontent.com/guy0090/la-dpsmeter/standalone/clone_install.ps1 -OutFile .\clone_install.ps1
```
### Run Script  
If you need to modify rpcapd default port or any other options, modify the script before running it.
```PowerShell
# Temporarily allow script execution for this PowerShell session
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process
.\clone_install.ps1
```

After the script finishes, navigate into the new `la-dpsmeter` folder and copy/rename `config.default.yml` to `config.yml`.  
For this example, only `p-cap-address` needs to be changed. Change it to **your local IP**.

Get your local IP with the following command ([src](https://stackoverflow.com/a/44685122)):
```PowerShell
(
    Get-NetIPConfiguration |
    Where-Object {
        $_.IPv4DefaultGateway -ne $null -and
        $_.NetAdapter.Status -ne "Disconnected"
    }
).IPv4Address.IPAddress
```

Once you've configured `config.yml`, uncomment lines `10-11` in `docker-compose.yml` and run `docker-compose -p loadps up -d` to start the container.  
Done! All logged packets by default are sent to `http://host.docker.internal:1338` (your host PCs IP)  

A [custom branch](https://github.com/guy0090/loa-details/tree/standalone) of LOA Details can be used to test your setup. You'll need to build it yourself to get it working.

```bash
# Clone and enter dir
git clone -b standalone https://github.com/guy0090/loa-details && cd loa-details

# Install packages
npm i

# Run in dev mode
npm run dev
```

### Manual Install
**SOON(tm)**

# WARNING
This is not endorsed by Smilegate or AGS. Usage of this tool isn't defined by Smilegate or AGS. I do not save your personal identifiable data. Having said that, the .pcap generated can potentially contain sensitive information (specifically, a one-time use token)
  