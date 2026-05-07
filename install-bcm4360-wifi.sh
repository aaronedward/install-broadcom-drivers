#!/bin/bash

# Ensure script is run as root
if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root (sudo ./install_wifi.sh)"
  exit
fi

echo "Updating package lists..."
apt update

echo "Cleaning up previous failed driver installations..."
# Purge old versions and clear DKMS crash logs to prevent build errors
rm -f /var/crash/broadcom-sta-dkms.0.crash
apt purge -y bcmwl-kernel-source broadcom-sta-common broadcom-sta-source broadcom-sta-dkms

echo "Installing Broadcom STA driver and dependencies..."
# Ubuntu 26.04 uses the broadcom-sta-dkms package for Kernel 7.0 compatibility
apt install -y broadcom-sta-dkms linux-headers-$(uname -r)

echo "Unloading conflicting modules..."
# These modules often conflict with the 'wl' driver for BCM4360
modprobe -r b43 bcma ssb brcmsmac brcmfmac

echo "Loading the 'wl' driver module..."
modprobe wl

echo "--------------------------------------------------------"
echo "Installation complete. Checking for wireless interface..."
ip link show | grep -E "wlan|wlp"

echo "--------------------------------------------------------"
echo "System will reboot in 10 seconds to apply changes."
echo "Press Ctrl+C to cancel."
sleep 10
reboot
