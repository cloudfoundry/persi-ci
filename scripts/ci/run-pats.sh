#!/bin/bash

set -ex

if [[ -z "${CONFIG_FILE_PATH}" ]]; then
  echo "Missing required CONFIG_FILE_PATH parameter."
  exit 1
fi

export CONFIG="${PWD}/${CONFIG_FILE_PATH}"

set +x
"${PWD}/persi-ci/scripts/ci/bbl_get_bosh_env"
source bosh-env/set-env.sh
set -x

pushd persi-acceptance-tests
  export GOPATH="${PWD}"
  export PATH="${GOPATH}/bin:${PATH}"

  if [[ -n "${PARALLEL_NODES}" ]]; then
    ./bin/test -flakeAttempts=3 --slowSpecThreshold=300 -nodes "${PARALLEL_NODES}" .
  else
    ./bin/test -flakeAttempts=3 --slowSpecThreshold=300 -p .
  fi
popd
