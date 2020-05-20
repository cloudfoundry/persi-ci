#!/usr/bin/env bash

set -euo pipefail

: "${VAR_RESOLVER_SCRIPT:?}"
: "${CF_USERNAME:?}"
: "${PLAN_NAME:?}"
: "${SERVICE_NAME:?}"

source "$(dirname $0)/helpers.sh"
source "${VAR_RESOLVER_SCRIPT}"

function write_config_to_file() {
  CONFIG_FILE="cats-config/cats.json"
  cat << EOF > ${CONFIG_FILE}
{
  "api": "api.${APPS_DOMAIN}",
  "apps_domain": "${APPS_DOMAIN}",
  "admin_user": "${CF_USERNAME}",
  "admin_password": "${CF_ADMIN_PASSWORD}",
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
  "volume_service_create_config": "${CREATE_CONFIG}"
}
EOF
}

set_cf_admin_password
set_cf_api_url
set_apps_domain
write_config_to_file