#!/bin/bash
set -e

echo "=== run.sh"

OHPC_IP=$(tofu output -raw ohpc_ipv6)
echo "--- wait for head $OHPC_IP"
while ! ssh ubuntu@$OHPC_IP hostname ; do echo . ; sleep .2 ; done

ansible --verbose all -m ping

ansible-playbook -v playbooks/system-ubuntu.yaml
ansible-playbook -v playbooks/warewulf-head.yaml
ansible-playbook -v playbooks/nodes.yaml --extra-vars image_name=ubuntu-24.04

echo ubuntu@$OHPC_IP
echo '--- done'
