#!/usr/bin/env bash

set -ex

source "$(dirname $0)/helpers.sh"

function validate_required_params() {
  # Required standard CATs config fields
  check_param APPS_DOMAIN
  check_param CF_API_ENDPOINT
  check_param CF_USERNAME

  # Required PATs config fields
  check_param PLAN_NAME
  check_param SERVICE_NAME
}

function set_cf_admin_password() {
  BOSH_ENV_NAME=$(cat smith-env/name)
  export env=$BOSH_ENV_NAME
  eval "$(smith -e $BOSH_ENV_NAME bosh)"
  export CF_ADMIN_PASSWORD=$(credhub find -j -n "uaa/admin_credentials" | jq -r '.credentials[].name' | xargs credhub get -j -n | jq -r '.value.password')
}

function set_required_params() {
  export APPS_DOMAIN=$(cat smith-env/metadata | jq -r '.apps_domain')
  export SYSTEM_DOMAIN=$(cat smith-env/metadata | jq -r '.sys_domain')
  export CF_API_ENDPOINT="api.${SYSTEM_DOMAIN}"
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

  if [[ -n "${BROKER_PASSWORD_KEY}" ]]; then
    broker_password="$(get_password_from_credhub "${BROKER_PASSWORD_KEY}")"
    updated_config=$(jq ".broker_password=\"${broker_password}\"" "${CONFIG_FILE}")
    echo "${updated_config}" > "${CONFIG_FILE}"
  fi
}

scripts_path="$(dirname "$0")"
source "${scripts_path}/utils.sh"

set_cf_admin_password
set_required_params
validate_required_params
write_config_to_file
