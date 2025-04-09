#!/bin/bash
set -e

echo "=== create.sh"

tofu apply -auto-approve -var-file=local.tfvars

./remove-knownhosts.sh

echo "=== create.sh ${OHPC_IP4} ${OHPC_IP6} ${OHPC_DNS}"
