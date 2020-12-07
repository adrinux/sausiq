# SAUSIQ

<u>S</u>emi <u>A</u>utomated <u>U</u>buntu <u>S</u>erver <u>I</u>n <u>Q</u>emu

A couple of shell scripts and a couple of cloud init config files to get an Ubuntu Server Cloud virtual machine running in Qemu. Uses the Ubuntu Server cloud image.

I use this for testing my Ansible roles before running them against actual cloud based virtual servers. Such as those at Linode (Please use my [referal URL](https://www.linode.com/?r=dab963ab63e7e4f2a6f32c334bf839513928ff5d) if you choose Linode as a host).

## Notes

_This has only been tested on manjaro linux._

Depends on the default network bridge created by the manjaro libvirt package, and uses the `cloud-localds` command (provided by the cloud-image-utils package on manjaro). Your own distro may vary.


## Networking

Default virbr0 (from install of libvirt) does NAT on the 192.168.122.0/24 network used by qemu.

These scripts set a fixed IP in that qemu subnet.

So:
```
192.168.122.20/24
```
gives IP of:
```
192.168.122.20
```

The default user is 'Ubuntu' with password 'linux', set in cloud_init.cfg

So the VM is reachable from your host with:
ssh ubuntu@192.168.122.20

But not from elsewhere on network.

You can generate a unique mac address for each VM with:
```
MAC_ADDR=$(printf '52:54:00:%02x:%02x:%02x' $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256))) && echo $MAC_ADDR
```

## File layout and base image

Actual VM uses the base cloud image as a backing file - changes are not saved to the original base image, multiple VMs can use same image (saves disk space \o/).

setup.sh will download the base cloud image if it is not present.


## Usage

- Start by copying the server-template folder to a new 'server-name' folder
- Generate a unique mac address and replace the one in `server-name/run.sh`
- Also replace mac address in `server-name/network_init.cfg`
- Set desired ip in `server-name/network_init.cfg`
- Change Hostname in `server-name/cloud_init.cfg`
- Add your ssh public key in `server-name/cloud_init.cfg`
- (optional) Change password in `server-name/cloud_init.cfg`
- (optional) Adjust memory and -smp details in `server-name/run.sh` (defaults to 2 Gigabytes of RAM and 2 CPU cores
- (optional) Increment tap interface number if you want to run more than one vm concurrently (default is tap0)
- 'cd server-name'
- Run `./setup.sh` - will download the circa 526mb cloud image if not present, be patient!
- Run `./run.sh`

If you kept the default fixed ip, username and have added your ssh public key you can log into your new VM with `ssh ubuntu@192.168.122.20`.

Allow enough time for cloud_init to install the qemu-guest-agent package then log in and shutdown.

You can then uncomment `-nographic` in `run.sh` for a headless vm.
On next run you'll need to shut down via SSH or do a hard shutdown with `quit` in qemu monitor.


