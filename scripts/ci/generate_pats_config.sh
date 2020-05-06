#!/usr/bin/env bash

set -ex

source "$(dirname $0)/helpers.sh"

scripts_path="$(dirname "$0")"
source "${scripts_path}/utils.sh"
source "${VAR_RESOLVER_SCRIPT}"

function validate_required_params() {
  # Required standard CATs config fields
  check_param APPS_DOMAIN
  check_param CF_API_ENDPOINT
  check_param CF_USERNAME

  # Required PATs config fields
  check_param PLAN_NAME
  check_param SERVICE_NAME
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
  "broker_password": "${BROKER_PASSWORD}"
  "isolation_segment": "${TEST_ISOLATION_SEGMENT}",
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

scripts_path="$(dirname "$0")"
source "${scripts_path}/utils.sh"

set_cf_admin_password
set_cf_api_url
set_apps_domain
validate_required_params
write_config_to_file