#!/bin/bash
set -e

echo "=== run.sh"

OHPC_IP=$(tofu output -raw ohpc_ipv6)
echo "--- wait for head $OHPC_IP"
while ! ssh ubuntu@$OHPC_IP hostname ; do echo . ; sleep .2 ; done

ansible --verbose all -m ping

ansible-playbook -v playbooks/ohpc-system-ubuntu.yaml

echo ubuntu@$OHPC_IP
echo '--- done'
