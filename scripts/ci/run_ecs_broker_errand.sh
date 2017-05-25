#!/usr/bin/env bash

#!/bin/bash

set -x -e

pushd ecs-broker-boshrelease

persi-ci/scripts/ci/bosh_setup
bosh -n create release --name ecs-broker-boshrelease --force && bosh -n upload release
bosh -d deployments-persi/ecs-broker-aws-ec2-manifest.yml -n run errand deploy-service-broker