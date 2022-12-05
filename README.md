# LostArk Logger and Custom Web Overlay (Docker)

A fork of [https://github.com/karaeren/LostArkLogger](https://github.com/karaeren/LostArkLogger) with the capability to
remote log packets via winpcap for Docker and display the logger in a custom web overlay.

![Image](https://safe.manu.moe/9Sxwowoi.jpg)

To display the overlay on top of Lost Ark, you can install the [tabfloater](https://www.tabfloater.io) extension.
For a darker browser theme, you can install the [Dark Reader](https://darkreader.org/) extension.

---
# Initial Setup (Windows)

We call the machine where you run Lost Ark the main computer.

Here are some options for where to run the Docker container containing the DPS meter:
1. On your main computer
2. On a Virtual Machine on your main computer
3. On a remote computer on the same network as your main computer

Evaluate your tolerance for risk (highest-to-lowest risk) and your tolerance for overhead (lowest-to-highest overhead).
If you are having issues with option (2) or (3) and don't want to do option (1), you can try a Virtual Machine fork.

## First step: Install Dependencies

This setup requires the following dependencies:  
- Install [Npcap](https://npcap.com/dist/npcap-1.71.exe) on your main computer.
  - Make sure to have the option `Install Npcap in WinPcap API-compatible Mode` checked.
- Install [Docker (Desktop)](https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe)
  - You can reference this [guide](https://docs.docker.com/desktop/install/windows-install/)
- Install [git](https://github.com/git-for-windows/git/releases/download/v2.38.1.windows.1/Git-2.38.1-64-bit.exe)

You will also want to open Windows PowerShell to run the commands in the following steps.

## Second step: Clone Repository

Clone this repository on the computer you will run the DPS meter on by running the following command in PowerShell:

```powershell
git clone https://github.com/therealhumes/la-dpsmeter.git
```

## Third step: Setup rpcapd

First, run the following command to make sure windows does not block unsigned software from being installed:

```powershell
Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy RemoteSigned -Force
```

Second, run the following script from the la-dpsmeter directory to install rpcapd:

```powershell
cd la-dpsmeter
.\bin\install-rpcapd.ps1
```

## Fourth step: Configure config.yml

Open the config.yml found in the la-dpsmeter folder and update the `p-cap-address` line to your IP address. 

You can get your local IP with the following command ([src](https://stackoverflow.com/a/44685122)):
```PowerShell
(
    Get-NetIPConfiguration |
    Where-Object {
        $_.IPv4DefaultGateway -ne $null -and
        $_.NetAdapter.Status -ne "Disconnected"
    }
).IPv4Address.IPAddress
```

Alternatively, you can run `ipconfig` in PowerSHell and pull the top local lan address.

## Fifth step: Run Container

Start up Docker if it is not already running. You will have installed this in the first step.

Run the following command from the la-dpsmeter directory.

```bash
docker run -d --name la-dpsmeter --restart unless-stopped -v ${pwd}/config.yml:/app/config.yml -v ${pwd}/logs:/mnt/raid1/apps/'Lost Ark Logs' -p 1338:1338 ghcr.io/therealhumes/la-dpsmeter:main
```

## Sixth step: Access Overlay

You can access the web overlay by opening the following url in your browser:

```
http://<dps-meter-machines-ip-address>:1338
```

If you are running the DPS meter on your main machine, this ip address will be the same as the fourth step.

# Future Updates

To update the container (or to kill it/refresh it), delete the old container and re-run or update the existing image.

To delete an old container, you can run the following Docker command:

```powershell
docker rm -f la-dpsmeter
```

To update the image, you have to pull the latest version of the docker image with the following command:

```bash
docker pull ghcr.io/therealhumes/la-dpsmeter:main
```

Then use the same run command from the fifth step.

# Support & Troubleshooting

We have a [discord server](https://discord.gg/bM8NtsJVeb) where you can ask questions or report bugs.

# WARNING

This is not endorsed by Smilegate or AGS. Usage of this tool isn't defined by Smilegate or AGS. I do not save your
personal identifiable data. Having said that, the .pcap generated can potentially contain sensitive information (
specifically, a one-time use token)