#!/bin/bash

set -x -e

function finish {
  pkill ssh || true
}
trap finish EXIT

bbl --state-dir bbl-state/${BBL_STATE_DIR} print-env > set-env.sh
source set-env.sh

bosh -n -d cf run-errand ${ERRAND_NAME} --instance ${INSTANCE_NAME} --when-changed
