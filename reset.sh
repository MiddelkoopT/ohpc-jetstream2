#!/bin/bash

echo "=== reset.sh"

./remove-knownhosts.sh

openstack server delete head c1 --wait
