#!/bin/bash

set -ex

if [[ -z "${CONFIG_FILE_PATH}" ]]; then
  echo "Missing required CONFIG_FILE_PATH parameter."
  exit 1
fi

export CONFIG="${PWD}/${CONFIG_FILE_PATH}"

set +x
${PWD}/persi-ci/scripts/ci/bbl_get_bosh_env
source bosh-env/set-env.sh
set -x

pushd release
  export GOPATH="${PWD}"
  export PATH="${GOPATH}/bin:${PATH}"

  pushd  src/code.cloudfoundry.org/persi-acceptance-tests
    if [[ -n "${PARALLEL_NODES}" ]]; then
      ./bin/test --slowSpecThreshold=300 -r -nodes "${PARALLEL_NODES}" .
    else
      ./bin/test --slowSpecThreshold=300 -r -p .
    fi
  popd
popd
