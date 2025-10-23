# QCA2066 WiFi 6E Backport for Steam Deck OLED

This project enables **WiFi 6E (6 GHz)** on the Steam Deck OLED by backporting the QCA2066 (ath11k) driver from Linux 6.16 to the Steam Deck's 6.11-based kernel.

> **Latest Release:** [ath11k-6.16v2](https://github.com/WanderingxLotus/steamdeck-oled-ath11k-dkms/releases/tag/ath11k-6.16v2)  
> **Asset:** [steamdeck-qca2066-backport-v1.0.1.tar.gz](https://github.com/WanderingxLotus/steamdeck-oled-ath11k-dkms/releases/download/ath11k-6.16v2/steamdeck-qca2066-backport-v1.0.1.tar.gz)

---

## 🚀 Install Using the Latest Release

### 1. Prepare Your Steam Deck

```bash
sudo steamos-readonly disable
sudo pacman-key --init
sudo pacman-key --populate archlinux holo
sudo pacman -S --needed --noconfirm base-devel linux-headers
```

### 2. Download and Extract the Release

Go to the [latest release page](https://github.com/WanderingxLotus/steamdeck-oled-ath11k-dkms/releases/tag/ath11k-6.16v2) and download **steamdeck-qca2066-backport-v1.0.1.tar.gz**.

Or via terminal:

```bash
cd ~/Downloads
wget https://github.com/WanderingxLotus/steamdeck-oled-ath11k-dkms/releases/download/ath11k-6.16v2/steamdeck-qca2066-backport-v1.0.1.tar.gz
tar xzvf steamdeck-qca2066-backport-v1.0.1.tar.gz
cd steamdeck-oled-ath11k-dkms
```

### 3. Install the Driver

```bash
sudo ./install.sh
```

This will:
- Build the driver from source (requires kernel headers)
- Install the `.ko` modules to `/lib/modules/$(uname -r)/extra/ath11k-backport/`
- Run `depmod -a`
- Reload the ath11k kernel modules

---

## ✅ Verifying the Install

```bash
sudo dmesg | tail -40 | grep -i ath11k
ip link show | grep wlan
iw dev
lsmod | grep ath11k
ping -c 3 8.8.8.8
```

You should see a new `wlan` interface and ath11k modules loaded.

---

## 🧹 Uninstall

```bash
sudo ./uninstall.sh
```

If needed, manually remove with:

```bash
sudo rm -f /lib/modules/"$(uname -r)"/extra/ath11k-backport/*.ko
sudo depmod -a
sudo modprobe -r ath11k_pci ath11k
sudo modprobe ath11k_pci
```

---

## ❗ Troubleshooting

- **Missing `/lib/modules/$(uname -r)/build` error:**  
  Install the matching kernel headers for your running kernel.

- **Unknown symbol / unresolved symbol errors:**  
  Ensure you have the correct headers and rebuild the modules.

- **Pacman key/auth errors:**  
  See the preparation step above.

- **Wi-Fi not working after install:**  
  Try rebooting, or reload modules:
  ```bash
  sudo modprobe -r ath11k_pci ath11k && sudo modprobe ath11k && sudo modprobe ath11k_pci
  ```

Still having trouble? Open an issue and include `uname -r`, `lsmod | grep ath11k`, and any relevant `dmesg` lines.

---

## 📝 License & Credits

Derived from the Linux kernel (GPL-2.0).  
Backport by: WanderingxLotus  
Original ath11k: Qualcomm & Linux kernel community
