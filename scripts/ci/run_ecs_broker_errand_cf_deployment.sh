#!/bin/bash

set -x -e

set +ux
pushd bbl-state
  eval "$(bbl print-env)"
popd
set -ux

bosh -n -d cf run-errand ecs-broker-deploy