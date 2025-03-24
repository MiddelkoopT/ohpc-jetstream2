#!/bin/bash
RECIPE=${1:-"recipe.sh"}

echo "=== test-recipe-run.sh $RECIPE"
OHPC_DNS=$(tofu output -raw ohpc_dns)
OHPC_USER=$(tofu output -raw ohpc_user)
HEAD="$OHPC_USER@$OHPC_DNS"

echo "--- wait for head $HEAD"
while ! ssh $HEAD hostname ; do echo . ; sleep .2 ; done

echo "--- setup head"
ssh $HEAD sudo bash <<- EOF
  dnf upgrade -y
  dnf install -y yum-utils initscripts-service ## AlmaLinux
  curl -sL -o /usr/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/') && chmod +x /usr/bin/yq
  nmcli c modify 'System eth0' ipv4.method shared
  nmcli c up 'System eth0'
  /usr/bin/needs-restarting -r || systemctl reboot
EOF

echo "--- wait for head $HEAD"
while ! ssh $HEAD hostname ; do echo . ; sleep .2 ; done

echo "--- run recipe"
scp ./test-recipe-config.sh $HEAD:
scp $RECIPE $HEAD:recipe.sh
ssh $HEAD "sudo OHPC_INPUT_LOCAL=./test-recipe-config.sh bash -x ./recipe.sh"

echo '--- done'
echo $OHPC_USER@$OHPC_DNS

