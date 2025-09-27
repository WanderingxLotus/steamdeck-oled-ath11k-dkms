# SteamDeck / SteamOS ath11k DKMS (QCA2066)

Persistent out-of-tree ath11k (QCA2066) driver package for SteamOS / Arch (Steam Deck), based on Linux 6.16 sources, backported to kernel 6.11.x series.

## Features
- DKMS auto-rebuild on kernel updates
- Updated firmware support (0x1101ffff generation)
- Removed unsupported `testmode` code paths for older cfg80211/mac80211 base
- Includes required shared headers (`spectral_common.h`, `testmode_i.h`)
- Optional auto firmware installer

## Installation

```bash
# 1. Install DKMS and kernel headers
# SteamOS/Arch:
sudo pacman -S dkms linux-headers
# Debian/Ubuntu:
# sudo apt install dkms linux-headers-$(uname -r)

# 2. Extract the DKMS driver package
tar xvf ath11k-steamos-dkms-6.16-custom.tar.gz
cd ath11k-dkms

# 3. Register and build
sudo dkms add .
sudo dkms install ath11k-steamos/6.16-custom

# 4. Install firmware (board-2.bin)
# If firmware/QCA2066/board-2.bin is missing, fetch manually:
git clone --depth 1 https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git
cp linux-firmware/ath11k/QCA2066/hw2.1/board-2.bin firmware/QCA2066/
sudo ./install.sh

# 5. Reload driver
sudo modprobe -r ath11k_pci ath11k || true
sudo modprobe ath11k_pci

# 6. Verify driver
modinfo ath11k_pci | grep filename
dmesg | grep -i ath11k | tail
```

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
