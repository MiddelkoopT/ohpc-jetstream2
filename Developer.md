# Developer Notes

Ongoing developer notes.  Don't forget to delete your lease when you are done.

## Chameleon
https://www.chameleoncloud.org/

### Create credentials

Application Credentials.  Create with all defaults, download clouds.yaml, and make sure `yq` is installed
```bash
./login.sh ~/Downloads/clouds.yaml cloud/chi.tacc.chameleoncloud.org.env
./login.sh ~/Downloads/clouds.yaml cloud/chi.uc.chameleon.env
```

### Create a reservation

Select IB based nodes with at least two active network cards (for example, `compute_cascadelake_r_ib` or `compute_haswell_ib`).  Tested at CHI@UC and CHI@TACC.  Reserve one IP, no need to reserve any network.

### Manual Config

* Create a network w/ a subnet (ohpc), disable default gateway and turn off DHCP.  Use `10.5.0.0/16` as the subnet. 
* When creating the instance, select sharednet1 as #1 and ohpc as #2.
* Turn off firewall

### Openstack
Login to OpenStack

Pick one based on the system your using
```bash
. ./auth-env.sh cloud/chi.tacc.chameleoncloud.org.env
. ./auth-env.sh cloud/chi.uc.chameleon.env
openstack project list
```

### Build Rocky9 Image

Build Image
* brew install cdrtools
* Linux OVMF file /usr/share/ovmf/OVMF.fd

```bash
touch meta-data
touch network-config
cat << EOF > user-data
#cloud-config
package_update: true
package_upgrade: true
packages:
  - kernel
  - linux-firmware
runcmd:
  - passwd -d root
power_state:
  delay: now
  mode: poweroff
  message: Powering off
  timeout: 2
  condition: true
EOF

mkisofs \
    -output seed.img \
    -volid cidata -rational-rock -joliet \
    user-data meta-data network-config

qemu-system-x86_64 -machine q35 -cpu Haswell-v4 -m 2G -smp 1 -bios OVMF.fd -drive file=head.qcow2,format=qcow2,if=virtio -drive file=seed.img,index=1,media=cdrom -nic user,model=virtio-net-pci -nographic
```

## IB

```bash
dnf install -y spack-ohpc ohpc-gnu13-openmpi5-parallel-libs \
    ohpc-gnu13-python-libs ohpc-gnu13-runtimes

dnf install -y infiniband-diags
modprobe mlx4_ib 
modprobe ib_umad 
modprobe ib_ipoib
ibstat
ibnodes

```