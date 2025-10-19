# QCA2066 WiFi 6E Support (backport)

Backport of QCA2066 (hw2.1) ath11k support from Linux 6.16 to a 6.11-based SteamOS kernel.
This repo contains source, build/install scripts and instructions.

Install:
  sudo ./install.sh

Verify:
  ip link show | grep wlan
  iwconfig
