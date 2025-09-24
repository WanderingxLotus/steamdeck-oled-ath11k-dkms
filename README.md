# SteamDeck / SteamOS ath11k DKMS (QCA2066)

Persistent out-of-tree ath11k (QCA2066) driver package for SteamOS / Arch (Steam Deck), based on Linux 6.16 sources, backported to kernel 6.11.x series.

## Features
- DKMS auto-rebuild on kernel updates
- Updated firmware support (0x1101ffff generation)
- Removed unsupported `testmode` code paths for older cfg80211/mac80211 base
- Includes required shared headers (`spectral_common.h`, `testmode_i.h`)
- Optional auto firmware installer

## Quick Install

```bash
git clone https://github.com/WanderingxLotus/steamdeck-ath11k-dkms.git
cd steamdeck-ath11k-dkms

# (Optional) Fetch board-2.bin if not committed:
./scripts/fetch_board_file.sh   # (create this if you choose not to ship the blob)

sudo pacman -S dkms
sudo dkms add .
sudo dkms install ath11k-steamos/6.16-custom

# Install firmware (if provided or fetched)
sudo ./install.sh

sudo modprobe -r ath11k_pci ath11k 2>/dev/null || true
sudo modprobe ath11k_pci
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
If you do **not** ship `board-2.bin`, instruct users to extract it:
```bash
git clone --depth 1 https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git
cp linux-firmware/ath11k/QCA2066/hw2.1/board-2.bin firmware/QCA2066/
sudo ./install.sh
```

## Known Benign Messages
- `ath11k: loading out-of-tree module taints kernel.` – normal for DKMS
- `Unexpected Regulatory event for this wiphy` – harmless

## Disabled
- `testmode.o` (cfg80211 testmode APIs absent in SteamOS 6.11 base)

See `BACKPORT_NOTES.md` for the technical delta.

## License
Driver source: original upstream Linux licensing (GPLv2). See LICENSE.
Firmware (if included): governed by vendor license; review WHENCE before redistribution.
