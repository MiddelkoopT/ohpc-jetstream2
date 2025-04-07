#!/bin/bash

echo "=== reset.sh"

openstack server delete head c1 --wait
