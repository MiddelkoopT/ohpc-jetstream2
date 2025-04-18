#!/bin/bash
## Source secure envrionment variables from pass
CLOUD_AUTH=${1:-cloud/jetstream.env}
echo "=== openstack auth-env.sh ${CLOUD_AUTH}"
source <(pass ${CLOUD_AUTH})
export OS_NAME OS_AUTH_URL OS_AUTH_TYPE OS_APPLICATION_CREDENTIAL_ID OS_APPLICATION_CREDENTIAL_SECRET
