#!/bin/bash

set -x -e

function finish {
  pkill ssh || true
}
trap finish EXIT

bbl --state-dir bbl-state/bbl-state print-env > set-env.sh
source set-env.sh

bosh -n -d cf run-errand ecs-broker-deploy