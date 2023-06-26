#!/usr/bin/env bash

# Check for Debian server base image
BASE=../base-images/debian-12-genericcloud-amd64.qcow2
if [[ -f "$BASE" ]]; then
  echo "$BASE found."
else
  echo "Fetching Debian Server 12 Bookworm generic cloud base image"
# download if not present
wget https://gemmei.ftp.acc.umu.se/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2 -P ../base-images
fi

# Check if we're written a mac address and write it if not
if grep "MACADDRESS" run.sh network_init.cfg; then
  echo "Generating random mac address"
  MAC_ADDR=$(printf '52:54:00:%02x:%02x:%02x' $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)))
  echo "$MAC_ADDR"
  echo "Writing random mac address to run.sh and network_init."
  sed -i "s/MACADDRESS/${MAC_ADDR}/g" run.sh
  sed -i "s/MACADDRESS/${MAC_ADDR}/g" network_init.cfg
else
  echo "Found mac address, skipping generation"
fi

# Check for VM disk image
DRIVE=system.qcow2
if [[ -f "$DRIVE" ]]; then
  echo "$DRIVE found."
else
  # Create if not present
  qemu-img create -f qcow2 -F qcow2 -o backing_file=$BASE $DRIVE
  # Resize
  qemu-img resize $DRIVE 10G
fi

# Create Cloud config image iso every time to pick up changes
CONFIG=cidata.iso
if [[ -f "$CONFIG" ]]; then
  echo "Cloud config disk image found. Removing."
  rm -rf $CONFIG
fi

CLOUD_INIT=cloud_init.cfg
NET_INIT=network_init.cfg

if [[ -f "$NET_INIT" ]]; then
  if [[ -f "$CLOUD_INIT" ]]; then
    echo "Generating cloud data disk iso"
    # Requires cloud-localds command installed
    cloud-localds -v --network-config=network_init.cfg cidata.iso cloud_init.cfg
  else
    echo "cloud_init.cfg file missing. Create and rerun"
  fi
else
  echo "network_init.cfg file missing. Create and rerun"
fi

