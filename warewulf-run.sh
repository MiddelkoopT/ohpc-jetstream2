#!/bin/bash
set -e

echo "=== warewulf-run.sh"
. ./get-env.sh
export OS_NAME

echo "--- wait for head $OHPC_HEAD"
while ! ssh $OHPC_USER@$OHPC_HEAD hostname ; do echo . ; sleep .2 ; done

ansible --verbose all -m ping

ansible-playbook -v playbooks/system-rocky.yaml
ansible-playbook -v playbooks/warewulf-head.yaml
ansible-playbook -v playbooks/image-rocky.yaml
ansible-playbook -v playbooks/nodes.yaml

echo $OHPC_USER@$OHPC_HEAD
echo '--- done'
