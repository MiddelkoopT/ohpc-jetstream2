# Development

## Debug

```bash
openstack console log show c0
ssh -i ~/.ssh/id_rsa -R 8180 c0
export all_proxy=socks5h://127.0.0.1:8180
scontrol update nodename=c1 state=RESUME
```

## Rocky 9 clean image

Run from a base Rocky image and use `head_image = "Rocky-9-GenericCloud-Base"` in `local.tf`
```bash
wget -c https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud-Base.latest.x86_64.qcow2
openstack image create --disk-format qcow2 --file Rocky-9-GenericCloud-Base.latest.x86_64.qcow2 --property hw_firmware_type='uefi' --property hw_scsi_model='virtio-scsi' --property hw_machine_type=q35 Rocky-9-GenericCloud-Base
```

## OpenHPC Development

OBS binary builds
* http://obs.openhpc.community:82/OpenHPC3:/3.2:/Factory/EL_9/
* http://obs.openhpc.community:82/OpenHPC3:/3.x:/Dep:/Release/EL_9/x86_64/ (ohpc-release, ohpc-release-factory)

Generate CI `recipe.sh`
```bash
../../../../parse_doc.pl steps.tex > recipe.sh 
```

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

# 3.1 Enable OpenHPC repository
dnf install -y http://repos.openhpc.community/OpenHPC/3/EL_9/x86_64/ohpc-release-3-1.el9.x86_64.rpm

## Run relevant recipe.sh from "Begin OpenHPC Recipe"

# Fix local node definitions
perl -pi -e 's/^NodeName=.*$/NodeName=c[1-4] State=UNKNOWN/' /etc/slurm/slurm.conf
perl -pi -e 's/^PartitionName=.*$/PartitionName=normal Nodes=c[1-4] Default=YES/' /etc/slurm/slurm.conf
systemctl restart slurmctld
```
