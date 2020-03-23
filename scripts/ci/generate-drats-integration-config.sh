#!/bin/bash

export SCRIPTS_ROOT_DIR="$(PWD)"
export BBL_PATH="$(which bbl)"

bbl() {
  for last; do true; done
  $BBL_PATH --metadata-file ${SCRIPTS_ROOT_DIR}/smith-env/metadata
}


ENV=`cat smith-env/metadata | jq -r ".name"`
export APPS_DOMAIN="${ENV}.cf-app.com"
export CF_API_ENDPOINT="api.${ENV}.cf-app.com"
export SYSTEM_DOMAIN="${ENV}.cf-app.com"

$SCRIPTS_ROOT_DIR/disaster-recovery-acceptance-tests/ci/credhub-compatible/update-integration-config/task.sh
