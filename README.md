# QCA2066 WiFi 6E Backport — Steam Deck OLED

This repository contains a backport of QCA2066 (hw2.1) ath11k driver support (from Linux 6.16) for Steam Deck kernels based on 6.11. It provides an easy script to build and install out‑of‑tree modules for decks that need QCA2066 WiFi 6E support.

Status: ✅ Tested on Steam Deck OLED (kernel: 6.11.11-valve24-2-neptune-611). Expected to enable 6 GHz (WiFi 6E) on QCA2066 (PCI ID 17cb:1109).

---

Quick notes: the install script builds the modules, copies them to
`/lib/modules/$(uname -r)/extra/ath11k-backport/`, runs `depmod -a`, and reloads the driver.

Important: you must have kernel headers that match your running kernel. If the build complains about a missing `/lib/modules/$(uname -r)/build` directory, install the matching headers or set KDIR to the headers path.

---

Simple copy/paste install (recommended)

1) Make the filesystem writable and install build tools (one-time only):
```bash
sudo steamos-readonly disable
sudo pacman-key --init
sudo pacman-key --populate archlinux holo
sudo pacman -S --needed --noconfirm base-devel linux-headers
```

2) Clone and run the installer:
```bash
cd /home/deck/build
git clone https://github.com/WanderingxLotus/steamdeck-oled-ath11k-dkms.git
cd steamdeck-oled-ath11k-dkms
sudo ./install.sh
```

That is all. The installer will:
- build the driver in src/
- copy .ko files to `/lib/modules/$(uname -r)/extra/ath11k-backport/`
- run `depmod -a`
- reload the ath11k modules

---

Manual build + install (if you prefer)

If you want to inspect/build by hand:

```bash
cd /home/deck/build/steamdeck-oled-ath11k-dkms/src

# Optional: set KDIR if your kernel headers are not at /lib/modules/$(uname -r)/build
# export KDIR=/path/to/your/linux-headers

make clean
make -j"$(nproc)"

# Install to an "extra" directory to avoid overwriting stock kernel modules
sudo mkdir -p /lib/modules/"$(uname -r)"/extra/ath11k-backport
sudo cp *.ko /lib/modules/"$(uname -r)"/extra/ath11k-backport/
sudo depmod -a

# Reload modules
sudo modprobe -r ath11k_pci ath11k_ahb ath11k 2>/dev/null || true
sudo modprobe ath11k
sudo modprobe ath11k_pci
```

---

Uninstall / revert

If you want to restore stock modules (if you backed them up), use:

```bash
cd /home/deck/build/steamdeck-oled-ath11k-dkms
sudo ./uninstall.sh
```

If uninstall.sh cannot find backups, you can manually remove the backport modules:
```bash
sudo rm -f /lib/modules/"$(uname -r)"/extra/ath11k-backport/*.ko
sudo depmod -a
sudo modprobe -r ath11k_pci ath11k
sudo modprobe ath11k_pci
```

---

Verify the install

Run these to confirm the driver is loaded and the interface is up:

```bash
# Check kernel messages for ath11k
sudo dmesg | tail -40 | grep -i ath11k

# Show wireless interfaces
ip link show | grep wlan

# Show interface details
iw dev
iwconfig

# Check kernel modules
lsmod | grep ath11k

# Test connectivity
ping -c 3 8.8.8.8
```

Expected: a wlan interface (e.g. `wlan1`) in UP/LOWER_UP state and ath11k modules present.

---

Troubleshooting (quick)

- Build error: `No such file or directory: /lib/modules/$(uname -r)/build`  
  → Install kernel headers matching your running kernel, or set `KDIR` to the directory that contains the headers:
  ```bash
  export KDIR=/path/to/linux-headers-<version>
  cd src && make clean && make
  ```

- Module load errors: "Unknown symbol" or many unresolved symbols  
  → Rebuild with the exact headers for your running kernel and ensure all .ko files (ath11k, ath11k_pci, ath11k_ahb) are installed to the same directory, then `depmod -a`.

- Authentication or package key errors while installing packages  
  → Initialize the pacman keyring (see install step: `pacman-key --init` and `--populate`) and try again.

---

Files in this repo

- src/ — driver sources and Makefile
- install.sh — build & install script (sudo)
- uninstall.sh — restore/remove script (sudo)
- README.md — this file

---

License & credits

This repository contains code derived from the Linux kernel (GPL-2.0). See source headers for details.

Backport by: WanderingxLotus  
Original ath11k driver: Qualcomm & Linux kernel community

---

If you want, I can also:
- produce a small one-line curl command to download the tarball/release, or
- add a tiny Quick Install badge to the top of this README.

Last updated: 2025-10-19
