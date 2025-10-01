# SteamDeck / SteamOS ath11k DKMS (QCA2066)

This package lets you use a custom WiFi driver for your Steam Deck or SteamOS device with QCA2066 hardware. It includes up-to-date kernel code, auto-rebuilds after updates, and fixes common Steam Deck WiFi issues.

---

## Features

- Stays working after SteamOS/kernel updates (DKMS)
- Newer firmware for better stability and compatibility
- Removes unsupported/test features
- Simple install with a provided tarball
- Sleep/wake WiFi fixes available

---

## What You’ll Need

- Steam Deck (or SteamOS device) in Desktop Mode
- The pre-release tarball from [Releases](https://github.com/WanderingxLotus/steamdeck-oled-ath11k-dkms/releases) (`ath11k-steamos-dkms-6.16-custom.tar.gz`)
- Basic internet (to download firmware if needed)
- Konsole app (the terminal)
- About 20 minutes and patience

---

## Installation (Step-by-Step)

### **Step 1: Download the Tarball**

Go to the [Releases page](https://github.com/WanderingxLotus/steamdeck-oled-ath11k-dkms/releases) and download the latest tarball:  
`ath11k-steamos-dkms-6.16-custom.tar.gz`

It will be in your **Downloads folder**:
```
/home/deck/Downloads
```

---

### **Step 2: Open Konsole (Terminal)**

- Press the Steam button
- Go to Power > Switch to Desktop
- Click the start menu (bottom left), search for "Konsole", and open it

---

### **Step 3: Make Your System Writable**

```bash
sudo steamos-readonly disable
```
If prompted for a password, type it and press Enter (or just press Enter).

---

### **Step 4: (First Time Only) Setup the Package Manager**

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
It will look like:  
`6.11.11-valve24-2-neptune-611-gfd0dd251480d`

---

### **Step 7: Install DKMS and Kernel Headers**

Replace `linux-neptune-611-headers` with the package matching your kernel version from step 6.

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
(Type `ls` to see the folder name if it’s different.)

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
No errors? You’re set!

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

## Advanced: Fix WiFi After Sleep/Wake

If your WiFi stops working after sleep/wake, you can set up a script to reload the driver automatically.

### **Remove Old Services and Scripts**

Run these commands to clean up anything from old guides:

```bash
sudo systemctl disable reload-ath11k.service
sudo systemctl disable close-moonlight.service
sudo rm /etc/systemd/system/reload-ath11k.service
sudo rm /etc/systemd/system/close-moonlight.service
sudo systemctl daemon-reload
sudo rm /usr/lib/systemd/system-sleep/reload-ath11k
sudo rm /usr/lib/systemd/system-sleep/close-moonlight
sudo rm /etc/systemd/logind.conf.d/ignore-lid.conf
sudo systemctl restart systemd-logind
rm ~/reload-ath11k.sh
rm ~/close-moonlight.sh
systemctl reboot
```

---

### **Set Up Automatic WiFi Driver Reload (Systemd Sleep Hook)**

#### 1. Make the reload script

```bash
cd ~
nano reload-ath11k.sh
```
Paste:
```bash
#!/bin/bash
sudo modprobe -r ath11k_pci ath11k
sleep 1
sudo modprobe ath11k_pci
sudo systemctl start NetworkManager
```
Save with `Ctrl+O`, `Enter`, `Ctrl+X`.  
Make it executable:

```bash
chmod +x ~/reload-ath11k.sh
```

#### 2. Add the systemd sleep hook

```bash
sudo nano /usr/lib/systemd/system-sleep/reload-ath11k
```
Paste:
```bash
#!/bin/bash
/home/deck/reload-ath11k.sh
```
Save and make executable:
```bash
sudo chmod +x /usr/lib/systemd/system-sleep/reload-ath11k
```

---

## Extra: Automatically Close Moonlight on Sleep/Wake

#### 1. Make the close script

```bash
cd ~
nano close-moonlight.sh
```
Paste:
```bash
#!/bin/bash
pkill moonlight
```
Save and make executable:
```bash
chmod +x ~/close-moonlight.sh
```

#### 2. Add the sleep hook

```bash
sudo nano /usr/lib/systemd/system-sleep/close-moonlight
```
Paste:
```bash
#!/bin/bash
/home/deck/close-moonlight.sh
```
Save and make executable:
```bash
sudo chmod +x /usr/lib/systemd/system-sleep/close-moonlight
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

To double-check:

```bash
sudo dmesg | grep -i ath11k | tail
dkms status
```

---

## License

Driver source: original upstream Linux GPLv2. See LICENSE.  
Firmware (if included): vendor license; review WHENCE before redistribution 