# QCA2066 WiFi 6E Backport for Steam Deck OLED

This project brings **WiFi 6E (6 GHz)** support to the Steam Deck OLED by backporting the QCA2066 (ath11k) driver from Linux 6.16 to the Steam Deck's 6.11-based kernels.

> **Tested:** Steam Deck OLED, kernel 6.11.11-valve24-2-neptune-611  
> **Enables:** QCA2066 WiFi 6E (PCI ID 17cb:1109)

---

## 🚀 Quick Start

### 1. Prepare Your System (one-time)

```bash
sudo steamos-readonly disable
sudo pacman-key --init
sudo pacman-key --populate archlinux holo
sudo pacman -S --needed --noconfirm base-devel linux-headers
```

### 2. Clone and Install

```bash
cd /home/deck/build
git clone https://github.com/WanderingxLotus/steamdeck-oled-ath11k-dkms.git
cd steamdeck-oled-ath11k-dkms
sudo ./install.sh
```

**The installer will:**
- Build the driver in `src/`
- Copy `.ko` files to `/lib/modules/$(uname -r)/extra/ath11k-backport/`
- Run `depmod -a`
- Reload the ath11k modules

---

## 🔧 Manual Build & Install (Advanced)

```bash
cd /home/deck/build/steamdeck-oled-ath11k-dkms/src

# Optional: If your kernel headers are in a nonstandard location
# export KDIR=/path/to/your/linux-headers

make clean
make -j"$(nproc)"

sudo mkdir -p /lib/modules/"$(uname -r)"/extra/ath11k-backport
sudo cp *.ko /lib/modules/"$(uname -r)"/extra/ath11k-backport/
sudo depmod -a

sudo modprobe -r ath11k_pci ath11k_ahb ath11k 2>/dev/null || true
sudo modprobe ath11k
sudo modprobe ath11k_pci
```

---

## 🧹 Uninstall / Revert

```bash
cd /home/deck/build/steamdeck-oled-ath11k-dkms
sudo ./uninstall.sh
```

If uninstall.sh can’t find backups, manually:
```bash
sudo rm -f /lib/modules/"$(uname -r)"/extra/ath11k-backport/*.ko
sudo depmod -a
sudo modprobe -r ath11k_pci ath11k
sudo modprobe ath11k_pci
```

---

## ✅ Verifying Your Install

Run these to ensure the driver is loaded and the interface is up:

```bash
sudo dmesg | tail -40 | grep -i ath11k
ip link show | grep wlan
iw dev
lsmod | grep ath11k
ping -c 3 8.8.8.8
```

You should see a `wlan` interface (`wlan1` etc.) and ath11k modules loaded.

---

## ❗ Troubleshooting

- **Missing `/lib/modules/$(uname -r)/build` error:**  
  Install the matching kernel headers, or set `KDIR` to your kernel header directory.

- **Unknown symbol / unresolved symbol errors:**  
  Double-check you’re building with the *exact* kernel headers for your running kernel. Rebuild and reinstall all `.ko` files, then `sudo depmod -a`.

- **Pacman key/auth errors:**  
  Run `sudo pacman-key --init` and `sudo pacman-key --populate archlinux holo` as in the quick start.

- **Network not working after install:**  
  Reboot, or reload modules:  
  `sudo modprobe -r ath11k_pci ath11k && sudo modprobe ath11k && sudo modprobe ath11k_pci`  
  Then check `ip link` and `dmesg`.

- **Still stuck?**  
  Please open an issue and include the output of `uname -r`, `lsmod | grep ath11k`, and any relevant `dmesg` lines.

---

## 📁 Repo Contents

- `src/` — driver source and Makefile
- `install.sh` — build & install script
- `uninstall.sh` — uninstall/revert script
- `README.md` — this file

---

## 📝 License & Credits

Derived from the Linux kernel (GPL-2.0).  
Backport by: WanderingxLotus  
Original ath11k: Qualcomm & Linux kernel community
