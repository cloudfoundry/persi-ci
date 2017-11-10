#!/bin/bash

set -e -x -u

source $(pwd)/ecs-lite-ci/scripts/ci/utils.sh
check_param ECS_URL
check_param AWS_REGION
check_param AWS_ACCESS_KEY_ID
check_param AWS_SECRET_ACCESS_KEY
check_param BUCKET
check_param ECS_DEPLOYMENT
check_param ECS_NODE_ID

### ecs-lite-ci
# Create bosh environment alias with certificate in ~/creds.yml
#bosh alias-env bosh-2 -e 10.249.246.81 --ca-cert <(bosh int ecs-lite-ci/creds.yml --path /director_ssl/ca)
#
#export BOSH_CLIENT=admin
#export BOSH_ENVIRONMENT=bosh-2
#export BOSH_CLIENT_SECRET=`bosh int ecs-lite-ci/creds.yml --path /admin_password`
#
#unset BOSH_ALL_PROXY

### gorgpphone

export DEBIAN_FRONTEND=noninteractive
sudo apt-get update
sudo apt-get install -y software-properties-common
sudo add-apt-repository -y ppa:webupd8team/java
sudo apt-get -y install openjdk-8-jdk
sudo apt-get -y install maven

pushd ecs-load-balancer-tests
    mvn clean test
popd
