#!/usr/bin/env bash

bbl --state-dir director-state/bbl-state print-env > set-env.sh
source set-env.sh
unset BOSH_ALL_PROXY
bosh cloud-config > temp.yml
bosh interpolate temp.yml -o persi-ci/operations/add-vip-network-to-bosh.yml > temp2.yml
bosh -n update-cloud-config temp2.yml
