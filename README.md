# SteamDeck / SteamOS ath11k DKMS (QCA2066)

Persistent out-of-tree ath11k (QCA2066) driver package for SteamOS / Arch (Steam Deck), based on Linux 6.16 sources, backported to kernel 6.11.x series.

## Features
- DKMS auto-rebuild on kernel updates
- Updated firmware support (0x1101ffff generation)
- Removed unsupported `testmode` code paths for older cfg80211/mac80211 base
- Includes required shared headers (`spectral_common.h`, `testmode_i.h`)
- Optional auto firmware installer

## Installation (Step-by-Step for Beginners)

These instructions assume you are brand new to Linux and using your Steam Deck in Desktop Mode.

---

### **Before You Begin**

- **Switch to Desktop Mode:**  
  Press the Steam button → Power → Switch to Desktop.

- **Open the Konsole app:**  
  Click the Application Launcher (bottom left corner), search for "Konsole", and open it.  
  The Konsole window is where you will copy and paste all the commands below.

- **What is a terminal/Konsole?**  
  The terminal (called "Konsole" on Steam Deck) is a special program for typing and running commands on your computer.  
  You will see a prompt ending with `$` or `deck@steamdeck ~)$`.

---

### **Understanding Your File System**

- Your files are organized in "folders" (also called "directories").
- The **Home folder** is where your personal files and downloads are.  
  When you open Konsole, you start in your Home folder.  
  You'll see this as `~` or `/home/deck` in the prompt.
- The **Downloads folder** is `/home/deck/Downloads`.

---

### **What Does "cd" Mean?**

- `cd` stands for "change directory" (move into a folder).
- Example:  
  `cd ~/Downloads` moves you into your Downloads folder.

---

### **Step 1: Make Your System Writable**

SteamOS protects system files by default. You need to unlock it:

```bash
sudo steamos-readonly disable
```
> When prompted for a password, type it and press Enter.  
> If you never set a password, just press Enter.

---

### **Step 2: Initialize the Package Manager (First Time Only)**

If you've never installed packages before, run:

```bash
sudo rm -rf /etc/pacman.d/gnupg
sudo pacman-key --init
sudo pacman-key --populate archlinux
```

---

### **Step 3: Trust the SteamOS Package Signing Key**

```bash
sudo pacman-key --recv-key AF1D2199EF0A3CCF
sudo pacman-key --lsign-key AF1D2199EF0A3CCF
```

---

### **Step 4: Find Your Kernel Version**

Run:

```bash
uname -r
```
> Copy the output. It will look like `6.11.11-valve24-2-neptune-611-gfd0dd251480d`.

---

### **Step 5: Install DKMS and Kernel Headers**

You must install DKMS and headers that match your kernel version.

Replace `linux-neptune-611-headers` with the package that matches your kernel version from Step 4.  
For example, if your kernel is `6.11.11-valve24-2-neptune-611-gfd0dd251480d`, you want `linux-neptune-611-headers`.

```bash
sudo pacman -S dkms linux-neptune-611-headers
```
> If you get an error that the package does not exist, ask for help in the Steam Deck community.

---

### **Step 6: Locate and Extract the Driver Package**

- If you downloaded the driver package (example: `ath11k-steamos-dkms-6.16-custom.tar.gz`), it will be in your **Downloads folder**.

First, move into your Downloads folder:

```bash
cd ~/Downloads
```

Extract the driver package:

```bash
tar xvf ath11k-steamos-dkms-6.16-custom.tar.gz
```

Move into the extracted folder (replace with your actual folder name if different):

```bash
cd steamdeck-oled-ath11k-dkms
```

---

### **Step 7: Register and Install the DKMS Module**

```bash
sudo dkms add .
sudo dkms install ath11k-steamos/6.16-custom
```

---

### **Step 8: Install the Firmware (board-2.bin)**

If you do not have the file `firmware/QCA2066/board-2.bin`, run:

```bash
git clone --depth 1 https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git
cp linux-firmware/ath11k/QCA2066/hw2.1/board-2.bin firmware/QCA2066/
sudo ./install.sh
```
> If you see "command not found" for `git`, install it with  
> `sudo pacman -S git`

---

### **Step 9: Reload the Driver**

```bash
sudo modprobe -r ath11k_pci ath11k || true
sudo modprobe ath11k_pci
```

---

### **Step 10: Verify the Custom Driver is Loaded**

```bash
modinfo ath11k_pci | grep filename
```
You should see a path ending in `/updates/dkms/ath11k_pci.ko.zst`.  
If so, your custom driver is in use.

---

### **Step 11: Check Driver Logs (optional, for troubleshooting)**

```bash
sudo dmesg | grep -i ath11k | tail
```

---

### **You’re Done!**

Your custom ath11k driver is installed and running.

- If you update your kernel or SteamOS, repeat Steps 4, 5, 7, and 9.

---

### **Troubleshooting Tips**

- **Missing kernel headers?**  
  Run Step 4 and make sure the headers package matches your kernel.
- **Signature errors?**  
  Repeat Steps 2 & 3.
- **Can't find files/folders?**  
  Double-check you are in the correct directory (use `pwd` to see your current folder).
- **Any error?**  
  Copy and paste the error message into Google or ask in the Steam Deck forums or GitHub issues.

---

### **Need More Help?**

Ask in the Steam Deck community or open an issue in this repository!

## Updating
1. Apply patches / refresh upstream snapshot (see `scripts/collect_upstream.sh`).
2. Bump `PACKAGE_VERSION` in `dkms.conf`.
3. Reinstall:
   ```bash
   sudo dkms remove ath11k-steamos/6.16-custom --all
   sudo dkms add .
   sudo dkms install ath11k-steamos/<new-version>
   ```

## Uninstall
```bash
sudo dkms remove ath11k-steamos/6.16-custom --all
```

## Firmware
If you do **not** ship `board-2.bin`,extract it:
```bash
git clone --depth 1 https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git
cp linux-firmware/ath11k/QCA2066/hw2.1/board-2.bin firmware/QCA2066/
sudo ./install.sh
```

## Known Benign Messages
- `ath11k: loading out-of-tree module taints kernel.` – normal for DKMS
- `Unexpected Regulatory event for this wiphy` – harmless

## Known Issue: Restarting on Wakeup

## Permanent Fixes for Suspend/Resume Issues

---

## Permanent Fixes for Suspend/Resume Issues

---

### **How to Remove Old or Broken Services (Clean Up)**

If you previously created workaround services or scripts (for WiFi, Moonlight, etc.), here’s how to safely remove them before setting up the new fixed versions:

**Remove systemd services:**
```bash
sudo systemctl disable reload-ath11k.service
sudo systemctl disable close-moonlight.service
sudo rm /etc/systemd/system/reload-ath11k.service
sudo rm /etc/systemd/system/close-moonlight.service
sudo systemctl daemon-reload
```

**Remove custom sleep hook scripts:**
```bash
sudo rm /usr/lib/systemd/system-sleep/reload-ath11k
sudo rm /usr/lib/systemd/system-sleep/close-moonlight
```

**Remove lid suspend block config (if you created it):**
```bash
sudo rm /etc/systemd/logind.conf.d/ignore-lid.conf
sudo systemctl restart systemd-logind
```

**Remove any leftover scripts from your home folder:**
```bash
rm ~/reload-ath11k.sh
rm ~/close-moonlight.sh
```

**Reboot to apply all changes:**
```bash
systemctl reboot
```

---

### **Set Up Fixed Working Services for Suspend/Resume**

#### **Automatically Reload WiFi Driver After Sleep (Suspend/Resume)**

1. **Create the reload script:**
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
    Save (`Ctrl+O`, `Enter`, `Ctrl+X`) and make executable:
    ```bash
    chmod +x ~/reload-ath11k.sh
    ```

2. **Create the systemd service:**
    ```bash
    sudo nano /etc/systemd/system/reload-ath11k.service
    ```
    Paste:
    ```
    [Unit]
    Description=Reload ath11k WiFi driver after resume
    After=suspend.target

    [Service]
    Type=oneshot
    ExecStart=/home/deck/reload-ath11k.sh

    [Install]
    WantedBy=suspend.target
    ```
    Save and exit.

3. **Enable the service:**
    ```bash
    sudo systemctl daemon-reload
    sudo systemctl enable reload-ath11k.service
    ```

---

#### **Automatically Close Moonlight on Sleep/Wake**

1. **Create the close script:**
    ```bash
    cd ~
    nano close-moonlight.sh
    ```
    Paste:
    ```bash
    #!/bin/bash
    pkill moonlight
    ```
    Save (`Ctrl+O`, `Enter`, `Ctrl+X`) and make executable:
    ```bash
    chmod +x ~/close-moonlight.sh
    ```

2. **Create the systemd service:**
    ```bash
    sudo nano /etc/systemd/system/close-moonlight.service
    ```
    Paste:
    ```
    [Unit]
    Description=Close Moonlight on suspend and resume
    After=suspend.target

    [Service]
    Type=oneshot
    ExecStart=/home/deck/close-moonlight.sh

    [Install]
    WantedBy=suspend.target
    ```
    Save and exit.

3. **Enable the service:**
    ```bash
    sudo systemctl daemon-reload
    sudo systemctl enable close-moonlight.service
    ```

---

**Check status anytime:**
```bash
sudo systemctl status reload-ath11k.service
sudo systemctl status close-moonlight.service
```
---

**Notes:**
- If your user is not `deck`, replace `/home/deck/` with your actual home directory.
- These services now reliably run after suspend (sleep/wake) and can be easily removed or edited using the above commands.

---

## License
Driver source: original upstream Linux licensing (GPLv2). See LICENSE.
Firmware (if included): governed by vendor license; review WHENCE before redistribution.
