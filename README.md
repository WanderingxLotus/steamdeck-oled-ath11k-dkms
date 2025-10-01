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

**Before you begin:**  
- Make sure you are in Desktop Mode (not Gaming Mode).
- Open the Konsole app (search for "Konsole" in the Steam Deck menu).

---

### **Step 1: Make your system writable**

SteamOS protects system files by default. You need to unlock it:

```bash
sudo steamos-readonly disable
```

---

### **Step 2: Initialize the package manager (first time only)**

If you've never installed packages before, run:

```bash
sudo rm -rf /etc/pacman.d/gnupg
sudo pacman-key --init
sudo pacman-key --populate archlinux
```

---

### **Step 3: Trust the SteamOS package signing key**

```bash
sudo pacman-key --recv-key AF1D2199EF0A3CCF
sudo pacman-key --lsign-key AF1D2199EF0A3CCF
```

---

### **Step 4: Install DKMS and kernel headers**

**You must install DKMS and the headers that match your kernel version.**

To check your kernel version, run:

```bash
uname -r
```

Then install DKMS and the correct headers (replace `linux-neptune-611-headers` with the package matching your kernel version from the previous command):

```bash
sudo pacman -S dkms linux-neptune-611-headers
```

If you are on Arch, it may be called `linux-headers` instead.

---

### **Step 5: Extract the driver package**

Navigate to your downloads folder, or wherever the driver package is located, then run:

```bash
tar xvf ath11k-steamos-dkms-6.16-custom.tar.gz
cd ath11k-dkms
```

---

### **Step 6: Register and install the DKMS module**

```bash
sudo dkms add .
sudo dkms install ath11k-steamos/6.16-custom
```

---

### **Step 7: Install the firmware (board-2.bin)**

If you do not have the firmware file (`firmware/QCA2066/board-2.bin`), download and install it:

```bash
git clone --depth 1 https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git
cp linux-firmware/ath11k/QCA2066/hw2.1/board-2.bin firmware/QCA2066/
sudo ./install.sh
```

---

### **Step 8: Reload the driver**

```bash
sudo modprobe -r ath11k_pci ath11k || true
sudo modprobe ath11k_pci
```

---

### **Step 9: Verify the driver is installed**

```bash
modinfo ath11k_pci | grep filename
```
You should see a path like `/updates/dkms/ath11k_pci.ko.zst`.

---

### **Step 10: Check dmesg for driver status**

```bash
sudo dmesg | grep -i ath11k | tail
```

---

**You're done! Your custom ath11k driver is installed and running. If you reboot or update your kernel, repeat steps 4, 6, 8, and 9.**

---

### **Troubleshooting**

- If you see errors about missing kernel headers, make sure you installed the package matching your kernel version (`uname -r`).
- If you see package signature errors, repeat Steps 2 & 3.
- For SteamOS updates, repeat these steps after updating.

---

**For further help, ask in the Steam Deck community or open an issue in this repository!**

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
As a workaround use the following and create a system servic:
```sudo modprobe -r ath11k_pci ath11k
# Suspend here (close lid)
# After wake:
sudo modprobe ath11k_pci
sudo systemctl start NetworkManager
```

## Disabled
- `testmode.o` (cfg80211 testmode APIs absent in SteamOS 6.11 base)

See `BACKPORT_NOTES.md` for the technical delta.


## License
Driver source: original upstream Linux licensing (GPLv2). See LICENSE.
Firmware (if included): governed by vendor license; review WHENCE before redistribution.
