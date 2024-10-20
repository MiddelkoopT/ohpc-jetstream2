# Development

## Debug

```bash
openstack console log show c0
ssh -i ~/.ssh/id_rsa -R 8180 c0
export all_proxy=socks5h://127.0.0.1:8180
scontrol update nodename=c0 state=RESUME
```

## Rocky 9 clean image

Run from a base Rocky image and use `head_image = "Rocky-9-GenericCloud-Base"` in `local.tf`
```bash
wget -c https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud-Base.latest.x86_64.qcow2
openstack image create --disk-format qcow2 --file Rocky-9-GenericCloud-Base.latest.x86_64.qcow2 --property hw_firmware_type='uefi' --property hw_scsi_model='virtio-scsi' --property hw_machine_type=q35 Rocky-9-GenericCloud-Base
```

## OpenHPC Documentation Tests

Development notes for testing OpenHPC documentation

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
internal_network=10.5.0.0
internal_netmask=255.255.0.0
compute_prefix=c
num_computes=4
c_ip[0]=10.5.1.1
c_ip[1]=10.5.1.2
c_ip[2]=10.5.1.3
c_ip[3]=10.5.1.4

# 3.1 Enable OpenHPC repository
dnf install -y http://repos.openhpc.community/OpenHPC/3/EL_9/x86_64/ohpc-release-3-1.el9.x86_64.rpm

## no need to install EPEL, CRB (Rocky8 Powertools) but works.
#dnf install -y dnf-plugins-core
#dnf config-manager --set-enabled crb

# 3.3 Head (install_provisioning_warewulf4_intro)
dnf -y install ohpc-base warewulf-ohpc hwloc-ohpc

systemctl enable chronyd.service
echo "local stratum 10" >> /etc/chrony.conf
echo "server ${ntp_server}" >> /etc/chrony.conf
echo "allow all" >> /etc/chrony.conf
systemctl restart chronyd

# 3.4 head slurm
dnf -y install ohpc-slurm-server
cp /etc/slurm/slurm.conf.ohpc /etc/slurm/slurm.conf
cp /etc/slurm/cgroup.conf.example /etc/slurm/cgroup.conf
perl -pi -e "s/SlurmctldHost=\S+/SlurmctldHost=${sms_name}/" /etc/slurm/slurm.conf

## FIXME: partitions - not in docs
perl -pi -e 's/^NodeName=.*$/NodeName=c[1-4] State=UNKNOWN/' /etc/slurm/slurm.conf
perl -pi -e 's/^PartitionName=.*$/PartitionName=normal Nodes=c[1-4] Default=YES/' /etc/slurm/slurm.conf

# 3.7 head warewulf (warewulf4_setup_centos)

## setup internal interface (not needed, already setup)
#ip link set dev ${sms_eth_internal} up
#ip address add ${sms_ip}/${internal_netmask} broadcast + dev ${sms_eth_internal}

# local: static IP's
perl -pi -e 's/^(dhcp:.*)/$1\n  template: static/' /etc/warewulf/warewulf.conf

perl -pi -e "s/ipaddr:.*/ipaddr: ${sms_ip}/" /etc/warewulf/warewulf.conf
perl -pi -e "s/netmask:.*/netmask: ${internal_netmask}/" /etc/warewulf/warewulf.conf
perl -pi -e "s/network:.*/network: ${internal_network}/" /etc/warewulf/warewulf.conf
perl -pi -e "s/template:.*/template: static/" /etc/warewulf/warewulf.conf
perl -pi -e "s/range start:.*/range start: ${c_ip[0]}/" /etc/warewulf/warewulf.conf
perl -pi -e "s/range end:.*/range end: ${c_ip[$((num_computes-1))]}/" /etc/warewulf/warewulf.conf
perl -pi -e "s/mount: false/mount: true/" /etc/warewulf/warewulf.conf

perl -pi -e "s/warewulf/${sms_name}/" /srv/warewulf/overlays/host/etc/hosts.ww
perl -pi -e "s/warewulf/${sms_name}/" /srv/warewulf/overlays/generic/etc/hosts.ww

systemctl enable --now warewulfd
wwctl overlay build
wwctl configure --all

# 3.8.1 Build BOS (warewulf4_mkchroot_rocky)
wwctl container import docker://ghcr.io/warewulf/warewulf-rockylinux:9 rocky-9.4 --syncuser


# 3.8.2 Add OpenHPC (warewulf4_add_to_compute_chroot_intro)
wwctl container exec rocky-9.4 /bin/bash <<EOF
dnf -y install http://repos.openhpc.community/OpenHPC/3/EL_9/x86_64/ohpc-release-3-1.el9.x86_64.rpm
dnf -y update
/bin/false
EOF

export CHROOT=/srv/warewulf/chroots/rocky-9.4/rootfs

# local debug
echo 'passwd -d root ; /bin/false' | wwctl container exec rocky-9.4 /bin/bash

# (warewulf4_add_to_compute_chroot_intro)
wwctl container exec rocky-9.4 /bin/bash <<EOF
dnf -y install ohpc-base-compute
/bin/false
EOF

# (steps)
wwctl container exec rocky-9.4 /bin/bash <<EOF
  # Add Slurm client support meta-package and enable munge and slurmd
  dnf -y install ohpc-slurm-client
  systemctl enable munge
  systemctl enable slurmd

  # Add Network Time Protocol (NTP) support
  dnf -y install chrony

  # Include modules user environment
  dnf -y install lmod-ohpc

  # defer image rebuild
  /bin/false
EOF

# 3.8.5 import files(import_ww4_files)
wwctl overlay import generic /etc/subuid
wwctl overlay import generic /etc/subgid

echo "server \${sms_ip} iburst" | wwctl overlay import generic <(cat) /etc/chrony.conf

# 3.8.5 configure slurm files (import_ww4_files_slurm)
wwctl overlay mkdir generic /etc/sysconfig/
wwctl overlay import generic <(echo SLURMD_OPTIONS="--conf-server ${sms_ip}") /etc/sysconfig/slurmd

wwctl overlay mkdir generic --mode 0700 /etc/munge
wwctl overlay import generic /etc/munge/munge.key
wwctl overlay chown generic /etc/munge/munge.key $(id -u munge) $(id -g munge)
wwctl overlay chown generic /etc/munge $(id -u munge) $(id -g munge)

# 3.9.1 finalize provisioning (finalize_warewulf4_provisioning)
wwctl container build rocky-9.4
wwctl overlay build

# 3.9.2 register nodes (add_ww4_hosts_intro)

## local: Map MAC to IP
unset c_mac
for ((i=0; i<$num_computes; i++)) ; do
  ping -q -c 1 -W 0.2 ${c_ip[$i]}
  c_mac[$i]=$(ip -json neigh | jq -r ".[] | select(.dst == \"${c_ip[$i]}\").lladdr")
done
echo ${c_mac[@]}

for ((i=0; i<$num_computes; i++)) ; do
  wwctl node delete --yes ${compute_prefix}$((i+1))
  wwctl node add --discoverable=yes --container=rocky-9.4 --ipaddr=${c_ip[$i]} --netmask=${internal_netmask} ${compute_prefix}$((i+1))
done

## local: register mac
for ((i=0; i<$num_computes; i++)) ; do
  if [[ ${c_mac[$i]} != 'null' ]] ; then 
    wwctl node set --yes ${compute_prefix}$((i+1)) --hwaddr=${c_mac[$i]}
  fi
done

# 3.9.2 finalize (add_ww4_hosts_finalize)
wwctl overlay build
wwctl configure --all

# 3.9.2 slurm (add_ww_hosts_slurm)
systemctl enable --now munge
systemctl enable --now slurmctld.service

```
