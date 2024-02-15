#!/bin/bash

CLOUD_CONFIG=${1:-cloud.yaml}
CLOUD_AUTH=${1:-cloud/jetstream.env}

echo "=== login.sh openstack ${CLOUD_CONFIG} ${CLOUD_AUTH}"

tee <<EOF | pass insert -m ${CLOUD_AUTH} 
OS_AUTH_URL=https://js2.jetstream-cloud.org:5000/v3/
OS_AUTH_TYPE=v3applicationcredential
OS_APPLICATION_CREDENTIAL_ID=$(yq .clouds.openstack.auth.application_credential_id < ${CLOUD_CONFIG})
OS_APPLICATION_CREDENTIAL_SECRET=$(yq .clouds.openstack.auth.application_credential_secret < ${CLOUD_CONFIG})
EOF
