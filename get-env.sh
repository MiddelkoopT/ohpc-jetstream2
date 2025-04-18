# Populate env

if [[ -z "${OS_NAME}" ]] ; then
  echo "no ./auth-env.sh"
  exit 1
fi

OHPC_IP4=$(tofu -chdir=${OS_NAME} output -raw ohpc_head_ipv4)
OHPC_IP6=$(tofu -chdir=${OS_NAME} output -raw ohpc_head_ipv6)
OHPC_DNS=$(tofu -chdir=${OS_NAME} output -raw ohpc_head_dns)
OHPC_HEAD=$(tofu -chdir=${OS_NAME} output -raw ohpc_head)
OHPC_USER=$(tofu -chdir=${OS_NAME} output -raw ohpc_user)

echo "--- env: ${OHPC_IP4} ${OHPC_IP6} ${OHPC_DNS} ${OHPC_USER}@${OHPC_HEAD}"
