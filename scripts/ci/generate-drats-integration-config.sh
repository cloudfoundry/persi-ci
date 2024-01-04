#!/bin/bash

wget https://github.com/cloudfoundry/bosh-bootloader/releases/download/v8.4.0/bbl-v8.4.0_linux_x86-64
chmod +x bbl-v8.4.0_linux_x86-64
mv bbl-v8.4.0_linux_x86-64 `which bbl`

export SCRIPTS_ROOT_DIR="${PWD}"
export BBL_PATH="$(which bbl)"
mkdir $SCRIPTS_ROOT_DIR/bbl-state

bbl() {
  for last; do true; done
  if [ $last = "jumpbox-address" ]; then
    cat ${SCRIPTS_ROOT_DIR}/cf-deployment-env/metadata | jq ".bosh.bosh_all_proxy" | sed -E 's#.*jumpbox@(.*)\?.*#\1#'
  else
    $BBL_PATH print-env --metadata-file ${SCRIPTS_ROOT_DIR}/cf-deployment-env/metadata
  fi
}

get_system_domain() {
  jq -r '.cf.api_url | capture("^api\\.(?<system_domain>.*)$") | .system_domain' \
    ${SCRIPTS_ROOT_DIR}/cf-deployment-env/metadata
}

ENV=`cat cf-deployment-env/metadata | jq -r ".name"`
export SYSTEM_DOMAIN="$(get_system_domain)"
export CF_API_ENDPOINT="api.${SYSTEM_DOMAIN}"
export APPS_DOMAIN="$SYSTEM_DOMAIN"
export -f bbl

if [[ -x "$UPDATE_INTEGRATION_CONFIG_SCRIPT" ]]; then
  "$UPDATE_INTEGRATION_CONFIG_SCRIPT"
else
  "$SCRIPTS_ROOT_DIR"/disaster-recovery-acceptance-tests/ci/tasks/update-integration-config/task.sh
fi
