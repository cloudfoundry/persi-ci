#!/usr/bin/env sh

set -e
export TERM=${TERM:-dumb}

cd ecs-cf-service-broker
./gradlew test