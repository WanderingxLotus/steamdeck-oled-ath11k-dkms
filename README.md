# SteamDeck / SteamOS ath11k DKMS (QCA2066)

This package gives you a custom WiFi driver for your Steam Deck or SteamOS device, based on the latest Linux sources. It supports the QCA2066 chip found in the OLED Steam Deck. The driver auto-rebuilds with kernel updates, uses the newest firmware, and includes fixes for sleep/wake WiFi issues.

---

## Features

- DKMS support (driver survives kernel/SteamOS updates)
- Improved firmware compatibility and performance
- Removes unsupported/test features
- Easy install via tarball release
- Modern suspend/resume workaround for WiFi issues

---

## What You’ll Need

- Steam Deck (or SteamOS device), switched to Desktop Mode
- The latest tarball from [Releases](https://github.com/WanderingxLotus/steamdeck-oled-ath11k-dkms/releases)
- Internet (for firmware download if needed)
- Konsole (the terminal app)
- About 20 minutes and patience

---

## Kernel & Upstream Driver Version

**This DKMS driver is based on upstream Linux kernel version 6.16.7 — commit [`131e2001572b`](https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git/commit/?id=131e2001572b).**

All `ath11k` source files in this package were compared against the official Linux 6.16.7 tree.  
**This repo contains compatibility and stability patches for the Steam Deck kernel (Valve’s 6.11.x), including:**
- Memory ordering fixes (`dma_rmb()`)
- Kernel API compatibility (timer macros, struct members, function args)
- Removal of new features not present on 6.11.x, and adaptation for hardware
- Minor bugfixes for Steam Deck platform

**In summary:**  
The base driver is Linux 6.16.7, but this DKMS package is not a vanilla copy—it contains targeted backports and patches for Steam Deck and SteamOS.

---

## Installation Steps

### **Step 1: Download the Tarball**

Visit the [Releases page](https://github.com/WanderingxLotus/steamdeck-oled-ath11k-dkms/releases) and download:
```
ath11k-steamos-dkms-6.16-custom.tar.gz
```
It will be in your **Downloads** folder:
```
/home/deck/Downloads
```

---

### **Step 2: Open Konsole**

- Press the Steam button
- Go to Power > Switch to Desktop
- Open the start menu (bottom left), search "Konsole", and launch it

---

### **Step 3: Make Your System Writable**

```bash
sudo steamos-readonly disable
```
If prompted for a password, type it and press Enter (if you never set one, just press Enter).

---

### **Step 4: (First Time Only) Prepare the Package Manager**

```bash
sudo rm -rf /etc/pacman.d/gnupg
sudo pacman-key --init
sudo pacman-key --populate archlinux
```

---

### **Step 5: (First Time Only) Add the Package Signing Key**

```bash
sudo pacman-key --recv-key AF1D2199EF0A3CCF
sudo pacman-key --lsign-key AF1D2199EF0A3CCF
```

---

### **Step 6: Find Your Kernel Version**

```bash
uname -r
```
Example output:  
`6.11.11-valve24-2-neptune-611-gfd0dd251480d`

---

### **Step 7: Install DKMS and Kernel Headers**

Replace `linux-neptune-611-headers` with the package matching your kernel version.

```bash
sudo pacman -S dkms linux-neptune-611-headers
```
If you get an error, ask for help in the Steam Deck community.

---

### **Step 8: Extract the Tarball**

Go to your Downloads folder:

```bash
cd ~/Downloads
```

Extract the tarball:

```bash
tar xvf ath11k-steamos-dkms-6.16-custom.tar.gz
```

Go into the new folder:

```bash
cd steamdeck-oled-ath11k-dkms
```
(Type `ls` to check the folder name if needed.)

---

### **Step 9: Register and Install the DKMS Driver**

```bash
sudo dkms add .
sudo dkms install ath11k-steamos/6.16-custom
```

---

### **Step 10: Install Firmware (if needed)**

If you see errors about missing `board-2.bin` or WiFi doesn’t work, run:

```bash
git clone --depth 1 https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git
cp linux-firmware/ath11k/QCA2066/hw2.1/board-2.bin firmware/QCA2066/
sudo ./install.sh
```
If you get a "git: command not found" error, install git:

```bash
sudo pacman -S git
```

---

### **Step 11: Reload the WiFi Driver**

```bash
sudo modprobe -r ath11k_pci ath11k || true
sudo modprobe ath11k_pci
```

---

### **Step 12: Confirm the Custom Driver is Loaded**

```bash
modinfo ath11k_pci | grep filename
```
You should see a path ending in `/updates/dkms/ath11k_pci.ko.zst`.  
This means your custom DKMS driver is loaded.

---

### **Step 13: (Optional) Check Driver Logs**

```bash
sudo dmesg | grep -i ath11k | tail
```
If there are no errors, you’re done!

---

## After Installation

- If you update your kernel or SteamOS, repeat Steps 6, 7, 9, and 11 to reinstall the driver.
- To uninstall, run:
```bash
sudo dkms remove ath11k-steamos/6.16-custom --all
```

---

## Troubleshooting

- **Missing kernel headers:** Make sure the header package matches your kernel version from Step 6.
- **Signature errors:** Repeat Steps 4 and 5.
- **Folder not found:** Use `ls` to see folder names and double-check your path.
- **Any error:** Copy the error message and ask in the Steam Deck forums or here on GitHub.

---

## Modern Suspend/Resume Workaround (Recommended)

If your WiFi drops or fails after sleep/wake, use this script to automatically unload and reload the driver, fixing Steam Deck reboot/wake issues.

### **Step 1: Add the system-sleep script**

Open Konsole and run:

```bash
sudo nano /usr/lib/systemd/system-sleep/ath11k-reload
```

Paste in:

```bash
#!/bin/bash
case $1 in
  pre)
    logger "system-sleep: Unloading ath11k_pci before suspend"
    modprobe -r ath11k_pci
    ;;
  post)
    logger "system-sleep: Reloading ath11k_pci after resume"
    modprobe ath11k_pci
    ;;
esac
```

Save (`Ctrl+O`, `Enter`, `Ctrl+X`).

Make it executable:

```bash
sudo chmod +x /usr/lib/systemd/system-sleep/ath11k-reload
```

---

**No other workaround scripts or systemd services are needed!  
Systemd will run this script automatically every time you suspend or resume.**

---

### **How to Check if It's Working**

After suspending and waking your Deck, check for log messages:

```bash
journalctl | grep system-sleep
```

You should see lines like:
```
system-sleep: Unloading ath11k_pci before suspend
system-sleep: Reloading ath11k_pci after resume
```

---

## How to Verify Your Custom Driver is Loaded

Run:

```bash
modinfo ath11k_pci | grep filename
```
You should see:
```
filename: /lib/modules/<kernel-version>/updates/dkms/ath11k_pci.ko.zst
```
If so, your custom DKMS driver is active!

Double-check with:

```bash
sudo dmesg | grep -i ath11k | tail
dkms status
```

---

## License

Driver source: original upstream Linux GPLv2. See LICENSE.  
Firmware (if included): vendor license; review WHENCE before redistribution.
