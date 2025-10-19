#!/bin/bash
set -e
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root: sudo ./uninstall.sh"
  exit 1
fi
KERNEL=$(uname -r)
BACKUP_DIR="/lib/modules/$KERNEL/kernel/drivers/net/wireless/ath/ath11k.stock-backup"
if [ -d "$BACKUP_DIR" ]; then
  mv "$BACKUP_DIR"/*.ko.zst /lib/modules/$KERNEL/kernel/drivers/net/wireless/ath/ath11k/ 2>/dev/null || true
  depmod -a
  modprobe -r ath11k_pci ath11k 2>/dev/null || true
  modprobe ath11k_pci || true
  echo "Stock modules restored (if backup existed)."
else
  echo "No backup directory found at $BACKUP_DIR"
fi
