## Test Recipe Configuration
# This gets sourced by the recipie.sh by setting OHPC_INPUT_LOCAL

## Head node configuration
ntp_server=pool.ntp.org
sms_name=head.novalocal
sms_ip=10.5.0.8
sms_eth_internal=eth1
internal_netmask=255.255.0.0
internal_network=10.5.0.0
ipv4_gateway=10.5.0.1
dns_servers=8.8.8.8

## Compute node configuration
eth_provision=eth0

## Cluster configuration
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

## Testing configuration
enable_nvidia_gpu_driver=0
provision_wait=1
update_slurm_nodeconfig=1
slurm_node_config="NodeName=c[1-4] State=UNKNOWN"

## Customize slurm.conf
# sed -i 's/^NodeName=.*$/NodeName=c[1-4] State=UNKNOWN/' /etc/slurm/slurm.conf
# sed -i 's/^PartitionName=.*$/PartitionName=normal Nodes=c[1-4] Default=YES/' /etc/slurm/slurm.conf

## Map MAC to IP on cluster
unset c_mac
for ((i=0; i<$num_computes; i++)) ; do
  ping -q -c 1 -W 0.2 ${c_ip[$i]}
  c_mac[$i]=$(ip -json neigh | jq -r ".[] | select(.dst == \"${c_ip[$i]}\").lladdr")
done
echo ${c_mac[@]}

## Setup OpenHPC Repo
# Local: Enable development repo (3.3)
dnf config-manager --add-repo http://obs.openhpc.community:82/OpenHPC3:/3.3:/Factory/EL_9/

# 3.1 Enable OpenHPC repository (not in recipe.sh)
dnf install -y http://repos.openhpc.community/OpenHPC/3/EL_9/x86_64/ohpc-release-3-1.el9.x86_64.rpm
