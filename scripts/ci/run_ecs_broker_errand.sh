#!/usr/bin/env bash

#!/bin/bash

set -x -e

persi-ci/scripts/ci/bosh_setup

pushd ecs-broker-boshrelease
bosh -n create release --name ecs-broker-boshrelease --force && bosh -n upload release
bosh -d deployments-persi/ecs-broker-aws-ec2-manifest.yml -n run errand deploy-service-broker