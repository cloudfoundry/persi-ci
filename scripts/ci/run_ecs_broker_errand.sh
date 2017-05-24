#!/usr/bin/env bash

#!/bin/bash

set -x -e

persi-ci/scripts/ci/bosh_setup
bosh -d deployments-persi/ecs-manifest.yml -n run errand deploy-service-broker