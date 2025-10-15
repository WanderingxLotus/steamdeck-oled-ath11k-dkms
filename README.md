# Steam Deck OLED ath11k Wi-Fi Driver DKMS Installer

This guide will walk you through installing the **ath11k Wi-Fi driver** for Steam Deck OLED on SteamOS or any compatible Linux.  
**No prior Linux experience needed—just follow the steps and copy/paste the commands.**

---

## Table of Contents

1. [What is this?](#what-is-this)
2. [What you need](#what-you-need)
3. [Step 1: Prepare your Steam Deck](#step-1-prepare-your-steam-deck)
4. [Step 2: Download the driver](#step-2-download-the-driver)
5. [Step 3: Install the driver](#step-3-install-the-driver)
6. [Step 4: Install the Wi-Fi firmware](#step-4-install-the-wi-fi-firmware)
7. [Step 5: Enable the driver](#step-5-enable-the-driver)
8. [Troubleshooting](#troubleshooting)
9. [Uninstalling](#uninstalling)
10. [FAQ](#faq)
11. [Credits](#credits)

---

## What is this?

This project provides an **updated Wi-Fi driver** (ath11k) and firmware for the Steam Deck OLED (QCA2066 chip).  
It fixes issues with sleep/wake, improves reliability, and makes Wi-Fi work on SteamOS after updates.

---

## What you need

- Steam Deck OLED (or compatible device)
- SteamOS or Linux (Desktop Mode)
- Internet access (for downloading files)
- **Terminal/Konsole** (find it in Desktop Mode)
- Your administrator password (Steam Deck default password is usually set during setup)

---

## Step 1: Prepare your Steam Deck

1. **Switch to Desktop Mode:**  
   - Press the Steam button, go to Power > Switch to Desktop.

2. **Open the Terminal:**  
   - Find "Konsole" or "Terminal" in your app launcher.

---

## Step 2: Download the driver

1. **Go to your Downloads folder:**  
   ```bash
   cd ~/Downloads
   ```

2. **Download the driver repository:**  
   ```bash
   git clone https://github.com/WanderingxLotus/steamdeck-oled-ath11k-dkms.git
   cd steamdeck-oled-ath11k-dkms
   ```

---

## Step 3: Install the driver with DKMS

1. **Make the installer script executable:**  
   ```bash
   chmod +x dkms-post-install.sh
   ```

2. **Install the driver using DKMS:**  
   ```bash
   sudo dkms add .
   sudo dkms install steamdeck-oled-ath11k-dkms/6.16-custom
   ```

   - Enter your password when prompted.

---

## Step 4: Install the Wi-Fi firmware

1. **Create the firmware directory:**  
   ```bash
   mkdir -p firmware/QCA2066
   ```

2. **Download the required firmware files:**  
   - Get **`board-2.bin`** (required) and **`firmware-2.bin`** (optional but recommended) for QCA2066.
   - Download from [linux-firmware repo QCA2066 section](https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/tree/ath11k/QCA2066/hw2.1).
   - Save them in your Downloads folder.

3. **Copy the firmware files:**  
   ```bash
   cp ~/Downloads/board-2.bin firmware/QCA2066/board-2.bin
   cp ~/Downloads/firmware-2.bin firmware/QCA2066/firmware-2.bin
   ```

   - Ignore errors if `firmware-2.bin` is missing; only `board-2.bin` is required.

4. **Run the post-install script to install the firmware:**  
   ```bash
   ./dkms-post-install.sh
   ```

---

## Step 5: Enable the driver

Reload the Wi-Fi modules to finish installation:

```bash
sudo modprobe -r ath11k_pci ath11k || true
sudo modprobe ath11k_pci
```

**Optional:** Restart your Steam Deck to ensure everything loads.

```bash
reboot
```

---

## Troubleshooting

- **Missing firmware error:**  
  Make sure you downloaded and copied `board-2.bin` to `firmware/QCA2066/`.

- **Wi-Fi not working after reboot:**  
  Try reloading the module again:
  ```bash
  sudo modprobe -r ath11k_pci ath11k || true
  sudo modprobe ath11k_pci
  ```

- **Not enough disk space:**  
  Delete unnecessary files from `~/Downloads` or elsewhere.

- **Still stuck?**  
  [Open an issue](https://github.com/WanderingxLotus/steamdeck-oled-ath11k-dkms/issues) and describe your problem.

---

## Uninstalling

Remove the driver and firmware changes:

```bash
sudo dkms remove steamdeck-oled-ath11k-dkms/6.16-custom --all
```

---

## FAQ

**Q: How do I open Konsole/Terminal?**  
A: In Desktop Mode, click the launcher and search for "Konsole" or "Terminal".

**Q: What if I don’t know my admin password?**  
A: You set it during Steam Deck setup. If you forgot, you’ll need to reset it in SteamOS.

**Q: Which firmware files do I need?**  
A: `board-2.bin` is required. `firmware-2.bin` is optional for some advanced features.

**Q: My Wi-Fi still doesn’t work after following all steps!**  
A: Double-check all commands, ensure firmware files are in the right location, and reboot. If the problem persists, open a GitHub issue.

---

## Credits

Created by [WanderingxLotus](https://github.com/WanderingxLotus)  
Thanks to everyone who tested and contributed!

---
