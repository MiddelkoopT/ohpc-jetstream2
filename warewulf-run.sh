#!/bin/bash
set -e

echo "=== warewulf-run.sh"

OHPC_DNS=$(tofu output -raw ohpc_dns)
OHPC_USER=$(tofu output -raw ohpc_user)
echo "--- wait for head $OHPC_DNS"
while ! ssh $OHPC_USER@$OHPC_DNS hostname ; do echo . ; sleep .2 ; done

ansible --verbose all -m ping

ansible-playbook -v playbooks/system-rocky.yaml
ansible-playbook -v playbooks/warewulf-head.yaml
ansible-playbook -v playbooks/image-rocky.yaml
ansible-playbook -v playbooks/nodes.yaml

echo $OHPC_USER@$OHPC_DNS
echo '--- done'
