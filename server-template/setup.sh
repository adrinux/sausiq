#!/usr/bin/env bash

# Check for ubuntu server base image
BASE=../base-images/focal-server-cloudimg-amd64-disk-kvm.img
if [[ -f "$BASE" ]]; then
  echo "$BASE found."
else
  echo "Fetching Ubuntu Server Cloud 20.04 base image"
# download if not present
wget https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64-disk-kvm.img -P ../base-images
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

