#!/bin/bash

CLOUD_CONFIG=${1:-clouds.yaml}
CLOUD_AUTH=${2:-cloud/jetstream.env}

echo "=== login.sh openstack ${CLOUD_CONFIG} ${CLOUD_AUTH}"

tee <<EOF | pass insert -m ${CLOUD_AUTH} 
OS_AUTH_URL=$(yq .clouds.openstack.auth.auth_url < ${CLOUD_CONFIG})
OS_AUTH_TYPE=v3applicationcredential
OS_APPLICATION_CREDENTIAL_ID=$(yq .clouds.openstack.auth.application_credential_id < ${CLOUD_CONFIG})
OS_APPLICATION_CREDENTIAL_SECRET=$(yq .clouds.openstack.auth.application_credential_secret < ${CLOUD_CONFIG})
EOF
