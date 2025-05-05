#!/bin/bash

IMAGE=${1:-"Rocky-9-GenericCloud"}

echo "=== snapshot.sh $IMAGE"
exit

. ./get-env.sh

ssh $OHPC_USER@$OHPC_HEAD sudo dnf update -y
ssh $OHPC_USER@$OHPC_HEAD sudo systemctl poweroff

openstack server stop head
openstack image delete ${IMAGE}-Snapshot
openstack server image create --name ${IMAGE}-Snapshot head
