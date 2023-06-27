#!/bin/bash

# Increment this for each vm you run concurrently
TAP_NO=tap0

# Check tap network is present
ip link show | grep $TAP_NO &> /dev/null
if [ $? -eq 0 ]; then
  echo "$TAP_NO exists"
else
  echo "$TAP_NO not present, starting...need sudo.."

  sudo ip tuntap add dev $TAP_NO mode tap
  sudo ip link set $TAP_NO up promisc on
  sudo ip link set dev virbr0 up
  sudo ip link set dev $TAP_NO master virbr0

  ip link show | grep $TAP_NO
fi


# Specify Qemu command line options
args=(
  -enable-kvm
  -m 4G
  -cpu host
  -machine q35,accel=kvm
  -smp 4,cores=2
  -netdev tap,id=net0,ifname=$TAP_NO,script=no,downscript=no
  -device virtio-net-pci,netdev=net0,id=net0,mac=MACADDRESS
  -drive file=cidata.iso,index=0,media=cdrom,format=raw
  -drive file=system.qcow2,index=1,media=disk,format=qcow2
  -vga none
  # -nographic
  -monitor stdio
)


# Run the vm
sudo qemu-system-x86_64 "${args[@]}"
