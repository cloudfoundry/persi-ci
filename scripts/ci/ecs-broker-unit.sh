#!/usr/bin/env sh

set -e

cd ecs-cf-service-broker
export GRADLE_OPTS=-Dorg.gradle.native=false
gradle -v
gradle test