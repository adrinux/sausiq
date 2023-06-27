# SAUSIQ

Well this branch is more like SADSIQ

_S_emi _A_utomated _D_ebian _S_erver _I_n _Q_emu


A couple of shell scripts and a couple of cloud init config files to get a Debian Server Cloud virtual machine running in Qemu. Uses the Debian Server generic image.

Currently the Debian 12 'Bookworm' image is hard coded but can be edited in setup.sh to a different version.

I use this for testing my Ansible roles before running them against actual cloud based virtual servers.

## Notes

_This has only been tested on manjaro linux._

Depends on the default network bridge created by the manjaro libvirt package, and uses the `cloud-localds` command (provided by the cloud-image-utils package on manjaro). Your own distro may vary.


## Networking

Relies on virb0 bridge provided by Virtual Machine Manager/libvirt so ensure those packages are installed.

Then start the libvert daemon:

```
sudo systemctl enable libvirtd.service
sudo systemctl start libvirtd.service
```
Should then be visible:
```
sudo virsh net-list --all

 Name      State    Autostart   Persistent
--------------------------------------------
 default   active   yes         yes

```

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

The default user is 'root' with password 'linux', set in cloud_init.cfg

The VM is reachable from your host with:
ssh root@192.168.122.20 and password 'linux'

But not from elsewhere on network.

## File layout and base image

Actual VM uses the base cloud image as a backing file - changes are not saved to the original base image, multiple VMs can use same image (saves disk space \o/).

setup.sh will download the base cloud image if it is not present.


## Usage

1. Start by copying the server-template folder contents to a new 'server-name' folder
2. Set desired ip in `server-name/network_init.cfg`
3. Change Hostname in `server-name/cloud_init.cfg`
4. Add your ssh public key in `server-name/cloud_init.cfg`
5. (optional) Change password in `server-name/cloud_init.cfg`
6. (optional) Adjust memory and -smp details in `server-name/run.sh` (defaults to 4 Gigabytes of RAM and 2 CPU cores
7. (optional) Increment tap interface number if you want to run more than one vm concurrently (default is tap0)
8. (optional) If you already downloaded the cloud image copy the base-images folder to the same directory as your server-name folder and place the image in it. eg directory layout:

```
| - debian-server
    | - server-name
        | cloud_init.cfg
        | network_init.cfg
        | run.sh
        | setup.sh
    | - base-images
        | debian-12-genericcloud-amd64.qcow2
```

9. 'cd server-name'
10. Run `./setup.sh` - will download the circa 526mb cloud image if not present, be patient!
11. Run `./run.sh`

Debian still tries to grab a dhcp address and will spend a couple of minutes waiting for networking before continuing boot. Be patient!

If you kept the default fixed ip, username and have added your ssh public key you can log into your new VM with `ssh root@192.168.122.20`.

Allow enough time for cloud_init to install the qemu-guest-agent package then log in, run apt update & apt upgrade and shutdown.

Then edit **run.sh** and:

1. Change -monitor from 'stdio' to 'none' (if you plan on running more than one vm concurrently).
2. (optional) Uncomment `-nographic` for a headless vm.

On next run you'll need to shut down via SSH (obviously).



