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
    cat ${SCRIPTS_ROOT_DIR}/smith-env/metadata | jq ".bosh.bosh_all_proxy" | sed -E 's#.*jumpbox@(.*)\?.*#\1#'
  else
    $BBL_PATH print-env --metadata-file ${SCRIPTS_ROOT_DIR}/smith-env/metadata
  fi
}


ENV=`cat smith-env/metadata | jq -r ".name"`
export APPS_DOMAIN="${ENV}.cf-app.com"
export CF_API_ENDPOINT="api.${ENV}.cf-app.com"
export SYSTEM_DOMAIN="${ENV}.cf-app.com"
export -f bbl

$SCRIPTS_ROOT_DIR/disaster-recovery-acceptance-tests/ci/credhub-compatible/update-integration-config/task.sh
