#!/usr/bin/env bash

set -e -x -u

function finish {
  pkill ssh || true
}
trap finish EXIT

bbl --state-dir director-state/${BBL_STATE_DIR} print-env > set-env.sh
source set-env.sh
bosh cloud-config > temp.yml
bosh interpolate temp.yml -o persi-ci/operations/add-vip-network-to-bosh.yml -o persi-ci/operations/change-minimal-vm-to-t2-nano.yml > temp2.yml
bosh -n update-cloud-config temp2.yml
