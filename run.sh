#!/bin/bash
set -e

echo "=== run.sh"

OHPC_DNS=$(tofu output -raw ohpc_dns)
echo "--- wait for head $OHPC_DNS"
while ! ssh rocky@$OHPC_DNS hostname ; do echo . ; sleep .2 ; done

ansible --verbose all -m ping

# FIXME: strange bugfix - not sure why this works but prevents dnf update failure
ssh rocky@$OHPC_DNS sudo dnf clean all

ansible-playbook -v playbooks/system-rocky.yaml
ansible-playbook -v playbooks/ohpc-head.yaml
ansible-playbook -v playbooks/nodes.yaml

echo rocky@$OHPC_DNS
echo '--- done'
