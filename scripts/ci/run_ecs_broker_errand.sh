#!/usr/bin/env bash

#!/bin/bash

set -x -e

persi-ci/scripts/ci/bosh_setup

bosh -d generated-manifest-ecs-broker/ecsbroker-aws-manifest.yml -n run errand deploy-broker