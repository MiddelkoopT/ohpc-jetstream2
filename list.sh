#!/bin/bash

echo "=== openstack list.sh"

openstack project list
openstack network list
openstack subnet list
openstack security group list
openstack server list
openstack floating ip list

echo "=== openstack list.sh done"
