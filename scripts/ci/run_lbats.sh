#!/bin/bash

set -e -x -u

source $(pwd)/ecs-lite-ci/scripts/ci/utils.sh
check_param ECS_MGMT_URL
check_param ECS_ADMIN_USER
check_param ECS_ADMIN_PASSWORD
check_param ECS_S3_URL
check_param AWS_REGION
#check_param ECS_ACCESS_KEY_ID
#check_param AWS_SECRET_ACCESS_KEY
check_param BUCKET
check_param ECS_DEPLOYMENT
check_param ECS_NODE_ID

uuid=`uuidgen`
ecs_access_key_id=lbats-user-${uuid}
aws_bucket=${BUCKET}-${uuid}

token=`curl -L --location-trusted -k ${ECS_MGMT_URL}/login -u "${ECS_ADMIN_USER}:${ECS_ADMIN_PASSWORD}" -I | grep -Fi X-SDS-AUTH-TOKEN | awk -F':' '{print $2}' | xargs`
echo ${token}

response=`curl ${ECS_MGMT_URL}/object/users -k  -X POST -H "X-SDS-AUTH-TOKEN: ${token}" -H "Content-Type: application/json"  -H "Accept: application/json" -H "x-emc-namespace: bosh-namespace" -d @- <<END;
{
    "user":"${ecs_access_key_id}",
    "namespace":"bosh-namespace",
    "tags":[""]
}
END`
echo ${response}

response=`curl ${ECS_MGMT_URL}/object/user-secret-keys/${ecs_access_key_id} -k  -X POST -H "X-SDS-AUTH-TOKEN: ${token}" -H "Content-Type: application/json" -H "Accept: application/json" -H "x-emc-namespace: bosh-namespace" -d '{"namespace": "bosh-namespace"}'`
echo ${response}
ecs_secret_key=`echo ${response} | jq -r '.secret_key'`

if [ ${ecs_secret_key} == "null" ]; then
    exit 1
fi

function tearDown {
    curl ${ECS_MGMT_URL}/object/users/deactivate -k  -X POST -H "X-SDS-AUTH-TOKEN: ${token}" -H "Content-Type: application/json" -H "Accept: application/json" -H "x-emc-namespace: bosh-namespace" -d @- <<END;
{
    "user":"${ecs_access_key_id}",
    "namespace": "bosh-namespace"
}
END
    curl ${ECS_MGMT_URL}/logout -k  -H "X-SDS-AUTH-TOKEN: ${token}" -H "Content-Type: application/json" -H "Accept: application/json" -H "x-emc-namespace: bosh-namespace"
}

trap tearDown EXIT

### ecs-lite-ci
# Create bosh environment alias with certificate in ~/creds.yml
#bosh alias-env bosh-2 -e 10.249.246.81 --ca-cert <(bosh int ecs-lite-ci/creds.yml --path /director_ssl/ca)
#
#export BOSH_CLIENT=admin
#export BOSH_ENVIRONMENT=bosh-2
#export BOSH_CLIENT_SECRET=`bosh int ecs-lite-ci/creds.yml --path /admin_password`
#
#unset BOSH_ALL_PROXY

### gorgophone
pushd gorgophone-env
    bbl print-env > setenv.sh
    source setenv.sh
popd

pushd ecs-load-balancer-tests
    ECS_ACCESS_KEY_ID=${ecs_access_key_id} \
    ECS_SECRET_KEY=${ecs_secret_key} \
    AWS_BUCKET=${aws_bucket} \
    DEPLOYMENT=${ECS_DEPLOYMENT} \
    ECS_SERVER_INSTANCE_ID=${ECS_NODE_ID} \
    mvn clean test
popd
