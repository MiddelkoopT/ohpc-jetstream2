#!/bin/bash
set -e

echo "=== create.sh"

tofu -chdir=${OS_NAME} apply -auto-approve -var-file=local.tfvars

. ./get-env.sh
. ./remove-knownhosts.sh

echo "=== create.sh ${OHPC_IP4} ${OHPC_IP6} ${OHPC_DNS}"
