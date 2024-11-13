#!/bin/bash
set -e

echo "=== run.sh"

OHPC_IP=$(tofu output -raw ohpc_ipv6)
echo "--- wait for head $OHPC_IP"
while ! ssh rocky@$OHPC_IP hostname ; do echo . ; sleep .2 ; done

ansible --verbose all -m ping

# FIXME: strange bugfix - not sure why this works but prevents dnf update failure
ssh rocky@$OHPC_IP sudo dnf clean all

ansible-playbook -v playbooks/system-rocky.yaml
ansible-playbook -v playbooks/ohpc-head.yaml
ansible-playbook -v playbooks/nodes.yaml

echo rocky@$OHPC_IP
echo '--- done'
