#!/usr/bin/env bash

set -euo pipefail

: "${VAR_RESOLVER_SCRIPT:?}"
: "${CF_USERNAME:?}"
: "${PLAN_NAME:?}"
: "${SERVICE_NAME:?}"

source "$(dirname $0)/helpers.sh"
source "${VAR_RESOLVER_SCRIPT}"

function get_system_domain() {
  jq -r '.cf.api_url | capture("^api\\.(?<system_domain>.*)$") | .system_domain' \
    smith-env/metadata
}

function setup_bosh_env_vars() {
  set +x
  if [ -d smith-env ]; then
    eval "$(bbl print-env --metadata-file smith-env/metadata)"
    export SYSTEM_DOMAIN="$(get_system_domain)"
    export TCP_DOMAIN="tcp.${SYSTEM_DOMAIN}"
  else
    echo "Must provide either smith-env as an input"
    exit 1
  fi
  set -x
}

function write_config_to_file() {
  # This config file contains fields from both the standard CATs config AND
  # the PATs config structs.
  CONFIG_FILE="pats-config/pats.json"
  cat << EOF > ${CONFIG_FILE}
{
  "admin_password": "$CF_ADMIN_PASSWORD",
  "admin_user": "${CF_USERNAME}",
  "api": "${CF_API_ENDPOINT}",
  "apps_domain": "${APPS_DOMAIN}",
  "artifacts_directory": "",
  "default_timeout": ${DEFAULT_TIMEOUT},
  "skip_ssl_validation": true,

  "broker_url": "${BROKER_URL}",
  "broker_user": "${BROKER_USER}",
  "broker_password": "${BROKER_PASSWORD}",
  "plan_name": "${PLAN_NAME}",
  "service_name": "${SERVICE_NAME}",

  "create_config": "${CREATE_CONFIG}",
  "create_bogus_config": "${CREATE_BOGUS_CONFIG}",
  "bind_config": ${BIND_CONFIG},
  "bind_bogus_config": "${BIND_BOGUS_CONFIG}",
  "disallowed_ldap_bind_config": "${DISALLOWED_LDAP_BIND_CONFIG}",
  "disallowed_override_bind_config": "${DISALLOWED_OVERRIDE_BIND_CONFIG}"
}
EOF
}

setup_bosh_env_vars
set_cf_admin_password
set_cf_api_url
set_apps_domain
write_config_to_file
