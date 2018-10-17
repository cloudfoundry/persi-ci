#!/bin/bash

set -e

persi-ci/scripts/ci/bbl_get_bosh_env
source bosh-env/set-env.sh

cf_password=`credhub find -j -n cf_admin_password | jq -r .credentials[].name | xargs credhub get -j -n | jq -r .value`

cat > /tmp/cats_integration_config.json <<EOF
{
  "api": "api.${APPS_DOMAIN}",
  "apps_domain": "${APPS_DOMAIN}",
  "admin_user": "${CF_USERNAME}",
  "admin_password": "${cf_password}",
  "backend": "diego",
  "skip_ssl_validation": true,
  "use_http": true,
  "include_apps": false,
  "include_backend_compatibility": false,
  "include_capi_experimental": false,
  "include_capi_no_bridge": false,
  "include_container_networking": false,
  "credhub_mode" : "",
  "include_detect": false,
  "include_docker": false,
  "include_internet_dependent": false,
  "include_isolation_segments": false,
  "include_private_docker_registry": false,
  "include_route_services": false,
  "include_routing": false,
  "include_routing_isolation_segments": false,
  "include_security_groups": false,
  "include_service_discovery": false,
  "include_services": false,
  "include_service_instance_sharing": false,
  "include_ssh": false,
  "include_sso": false,
  "include_tasks": false,
  "include_v3": false,
  "include_zipkin": false,
  "include_assisted_credhub": false,
  "include_credhub": false,
  "include_tcp_routing": false,
  "include_volume_services": true,
  "volume_service_name": "${SERVICE_NAME}",
  "volume_service_plan_name": "${PLAN_NAME}",
  "volume_service_create_config": "${CREATE_CONFIG}",
  "volume_service_bind_config": "${BIND_CONFIG}"
}
EOF

export GOPATH=$PWD
pushd src/github.com/cloudfoundry/cf-acceptance-tests/
  CONFIG=/tmp/cats_integration_config.json ./bin/test -v
popd
