#!/bin/bash
set -e
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root: sudo ./install.sh"
  exit 1
fi
KERNEL=$(uname -r)
echo "Building modules for kernel: $KERNEL"
cd src
make clean || true
make -j"$(nproc)"
mkdir -p /lib/modules/$KERNEL/extra/ath11k-backport
cp *.ko /lib/modules/$KERNEL/extra/ath11k-backport/
depmod -a
# reload drivers
modprobe -r ath11k_pci ath11k_ahb ath11k 2>/dev/null || true
sleep 1
modprobe ath11k
modprobe ath11k_pci
echo "Install complete. Check: ip link show | grep wlan"
