#!/bin/bash
set -euo pipefail

echo "[ath11k-steamos] Installing QCA2066 firmware blobs..."

SRC_DIR="$(dirname "$0")/firmware/QCA2066"
LOWER_DST="/lib/firmware/ath11k/qca2066/hw2.1"
UPPER_DST="/lib/firmware/ath11k/QCA2066/hw2.1"

if [[ ! -f "${SRC_DIR}/board-2.bin" ]]; then
  echo "ERROR: Missing ${SRC_DIR}/board-2.bin"
  exit 1
fi

sudo mkdir -p "${LOWER_DST}" "${UPPER_DST}"

sudo install -m 0644 "${SRC_DIR}/board-2.bin" "${LOWER_DST}/board-2.bin"
sudo install -m 0644 "${SRC_DIR}/board-2.bin" "${UPPER_DST}/board-2.bin"

if [[ -f "${SRC_DIR}/firmware-2.bin" ]]; then
  sudo install -m 0644 "${SRC_DIR}/firmware-2.bin" "${LOWER_DST}/firmware-2.bin"
  sudo install -m 0644 "${SRC_DIR}/firmware-2.bin" "${UPPER_DST}/firmware-2.bin"
fi

# Legacy name
sudo cp "${LOWER_DST}/board-2.bin" "${LOWER_DST}/board.bin"
sudo cp "${UPPER_DST}/board-2.bin" "${UPPER_DST}/board.bin"

echo "[ath11k-steamos] Done. Reload modules:"
echo "  sudo modprobe -r ath11k_pci ath11k || true"
echo "  sudo modprobe ath11k_pci"
