#!/bin/bash

echo "=== delete.sh"

. ./get-env.sh
. ./remove-knownhosts.sh

tofu -chdir=${OS_NAME} destroy -auto-approve -var-file=local.tfvars
