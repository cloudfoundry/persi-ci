#!/bin/sh

set -eux

export DOCKER_STORAGE_OPTIONS='--storage-opt dm.basesize=100G'
start-bosh

export DOCKER_TMP_DIR=$(find /tmp/ -name "tmp.*")
export DOCKER_HOST=$(ps aux | grep dockerd | grep -o '\-\-host tcp.*4243' | awk '{print $2}')

eval "$(cat /tmp/local-bosh/director/env)"

sleep 36000

