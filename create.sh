#!/bin/bash
set -e

echo "=== create.sh"

tofu apply -auto-approve -var-file=local.tfvars

echo "--- removing known-hosts entries"

OHPC_IP4=$(tofu output -raw ohpc_ipv4)
if [[ -n "${OHPC_IP4}" ]] ; then
  ssh-keygen -R $OHPC_IP4
fi

OHPC_IP6=$(tofu output -raw ohpc_ipv6)
if [[ -n "${OHPC_IP6}" ]] ; then
  ssh-keygen -R $OHPC_IP6
fi

OHPC_DNS=$(tofu output -raw ohpc_dns)
if [[ -n "${OHPC_DNS}" ]] ; then
  ssh-keygen -R $OHPC_DNS
fi

echo "=== create.sh ${OHPC_IP4} ${OHPC_IP6} ${OHPC_DNS}"
