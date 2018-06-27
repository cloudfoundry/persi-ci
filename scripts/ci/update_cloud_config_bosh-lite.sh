#!/usr/bin/env bash

set -e -x -u

source persi-ci/efs/shared-functions

trap teardown_bosh_env_vars EXIT

setup_bosh_env_vars_with_ssh
bosh -n update-cloud-config persi/efs/cloud-config.yml
teardown_bosh_env_vars