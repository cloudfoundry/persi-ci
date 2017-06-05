#!/usr/bin/env bash

#!/bin/bash

set -x -e

persi-ci/scripts/ci/bosh_setup

pushd ecs-release
bosh -n create release --name ecs-release --force && bosh -n upload release
popd
bosh -d deployments-persi/ecs-broker-aws-ec2-manifest.yml -n run errand deploy-service-broker