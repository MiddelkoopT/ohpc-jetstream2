# Developer Notes

Ongoing developer notes.  Don't forget to delete your lease when you are done.

## Debug

```bash
openstack console log show c0
ssh -i ~/.ssh/id_rsa -R 8180 c0
export all_proxy=socks5h://127.0.0.1:8180
scontrol update nodename=c1 state=RESUME
```

Connect to the serial port directly.
```bash
websocat -b $(openstack console url show -f json --serial c1 | jq -r .url)
(stty raw ; websocat -b $(openstack console url show -f json --serial c1 |jq -r .url) ; stty sane)
```

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

## Documentation

### Rocky 9 clean image

Run from a base Rocky image and use `head_image = "Rocky-9-GenericCloud-Base"` in `local.tf`
```bash
openstack image delete Rocky-9-GenericCloud-Base
wget -c https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud-Base.latest.x86_64.qcow2
openstack image create --disk-format qcow2 --file Rocky-9-GenericCloud-Base.latest.x86_64.qcow2 --property hw_firmware_type='uefi' --property hw_scsi_model='virtio-scsi' --property hw_machine_type=q35 Rocky-9-GenericCloud-Base
openstack image show Rocky-9-GenericCloud-Base
```

### OBS

OBS binary builds
* http://obs.openhpc.community:82/OpenHPC3:/3.2:/Factory/EL_9/
* http://obs.openhpc.community:82/OpenHPC3:/3.x:/Dep:/Release/EL_9/x86_64/ (ohpc-release, ohpc-release-factory)

### Run a Recipe

Generate CI `recipe.sh`
```bash
../../../../parse_doc.pl steps.tex > recipe.sh 
```

Build notes
```bash
# 0 setup
#sudo -i
export YUM_MIRROR_BASE=https://mirror.usi.edu/pub/rocky
dnf upgrade -y
/usr/bin/needs-restarting -r || systemctl reboot

# 1.3 inputs
#sudo -i
unalias cp mv rm
export YUM_MIRROR_BASE=https://mirror.usi.edu/pub/rocky

ntp_server=pool.ntp.org
sms_name=head
sms_ip=10.5.0.8
sms_eth_internal=eth1
internal_netmask=255.255.0.0
internal_network=10.5.0.0
ipv4_gateway=10.5.0.1
dns_servers=8.8.8.8
compute_prefix=c
num_computes=1
c_ip[0]=10.5.1.1
c_ip[1]=10.5.1.2
c_ip[2]=10.5.1.3
c_ip[3]=10.5.1.4
c_name[0]=c1
c_name[1]=c2
c_name[2]=c3
c_name[3]=c4

## local: Map MAC to IP
unset c_mac
for ((i=0; i<$num_computes; i++)) ; do
  ping -q -c 1 -W 0.2 ${c_ip[$i]}
  c_mac[$i]=$(ip -json neigh | jq -r ".[] | select(.dst == \"${c_ip[$i]}\").lladdr")
done
echo ${c_mac[@]}

# Local: Enable dev (use for 3.x branch/Warewulf 4.5)
dnf config-manager --add-repo http://obs.openhpc.community:82/OpenHPC3:/3.2:/Factory/EL_9/

# 3.1 Enable OpenHPC repository (not in recipe.sh)
dnf install -y http://repos.openhpc.community/OpenHPC/3/EL_9/x86_64/ohpc-release-3-1.el9.x86_64.rpm

## Run "Add baseline OpenHPC" (3.3) and "Add resource management" (3.4)

# Local: Patch templates for local hardware.
sed -i 's/^NodeName=.*$/NodeName=c[1-4] State=UNKNOWN/' /etc/slurm/slurm.conf
sed -i 's/^PartitionName=.*$/PartitionName=normal Nodes=c[1-4] Default=YES/' /etc/slurm/slurm.conf

## Remainder of recipe.sh

```

## HPC Ecosystems Lab 3.0

Resources
* https://github.com/HPC-Ecosystems/openhpc-3.x-virtual-lab

```bash
sms_name=head
sms_ip=10.5.0.8
internal_network=10.5.0.0/16
```

## JupyterBook

### Remote bash kernel

Install Jupyter locally
```bash
python3 -m venv .venv
. .venv/bin/activate

python3 -m pip install pip --upgrade
python3 -m pip install --upgrade jupyterlab
python3 -m pip install --upgrade bash_kernel
python3 -m bash_kernel.install
python3 -m pip install --upgrade jupyterlab-spellchecker
python3 -m pip install remote-kernel
```

Install bash_kernel on remote
```bash
sudo dnf install -y python3-pip
sudo python3 -m pip install pip --upgrade
sudo python3 -m pip install --upgrade bash_kernel
sudo python3 -m bash_kernel.install
```

Configure locally the remote kernel (key must be rsa and have no passphrase)
```bash
python -m remote_kernel install -t rocky@head -i ~/.ssh/id_dev --kernel 'python3 -m bash_kernel'
jupyter kernelspec list
```

Run Jupyter locally
```bash
jupyter-lab --port=8081
```
## Warewulf Build

Run Warewulf
```bash
./create.sh
OHPC_IP=$(tofu output -raw ohpc_ipv6)
while ! ssh rocky@$OHPC_IP hostname ; do echo . ; sleep .2 ; done
ssh rocky@$OHPC_IP sudo dnf clean all
ansible-playbook -v playbooks/system-rocky.yaml

ansible-playbook -v playbooks/warewulf-head.yaml
ansible-playbook -v playbooks/container-rocky.yaml
ansible-playbook -v playbooks/nodes.yaml
```

## Ubuntu Images

local.tfvars
```ini
head_image = "Featured-Minimal-Ubuntu24"
head_user = "ubuntu"
```

```bash
./create.sh
OHPC_IP=$(tofu output -raw ohpc_ipv6)
while ! ssh ubuntu@$OHPC_IP hostname ; do echo . ; sleep .2 ; done
ansible-playbook -v playbooks/system-ubuntu.yaml
ansible-playbook -v playbooks/warewulf-head.yaml
ansible-playbook -v playbooks/container-ubuntu.yaml
ansible-playbook -v playbooks/nodes.yaml
```
