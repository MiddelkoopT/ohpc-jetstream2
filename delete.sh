#!/bin/bash

echo "=== delete.sh"

./remove-knownhosts.sh

tofu destroy -auto-approve -var-file=local.tfvars
