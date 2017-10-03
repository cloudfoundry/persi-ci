#!/usr/bin/env bash

bbl --state-dir director-state print-env > set-env.sh
source set-env.sh
bosh cloud-config > temp.yml
bosh interpolate temp.yml -o persi-ci/operations/add-vip-network-to-bosh.yml -o persi-ci/operations/use-efsbroker-for-iam-instance-profile.yml > temp2.yml
bosh -n update-cloud-config temp2.yml
