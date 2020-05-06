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
  "service_name": "${SERVICE_NAME}"
}
EOF

  local bind_config_file="${PWD}/bind-config.json"

  if [[ -r "${PWD}/bind-create-config/bind-config.json" ]]; then
    cp "${PWD}/bind-create-config/bind-config.json" "${bind_config_file}"
  elif [[ -n "${BIND_CONFIG}" ]]; then
    echo "${BIND_CONFIG}" > "${bind_config_file}"
  else
    echo "" > "${bind_config_file}"
  fi

  updated_config=$(jq --argjson bindConfig "$(cat "${bind_config_file}")" '.bind_config=$bindConfig' "${CONFIG_FILE}")
  echo "${updated_config}" > "${CONFIG_FILE}"

  if [[ -n "${BIND_BOGUS_CONFIG}" ]]; then
    echo "${BIND_BOGUS_CONFIG}" > "${bind_config_file}"
  else
    echo "" > "${bind_config_file}"
  fi

  updated_config=$(jq --arg bindConfig "$(cat "${bind_config_file}")" '.bind_bogus_config=$bindConfig' "${CONFIG_FILE}")
  echo "${updated_config}" > "${CONFIG_FILE}"

  if [[ -n "${DISALLOWED_LDAP_BIND_CONFIG}" ]]; then
    echo "${DISALLOWED_LDAP_BIND_CONFIG}" > "${bind_config_file}"
  else
    echo "" > "${bind_config_file}"
  fi

  updated_config=$(jq --arg bindConfig "$(cat "${bind_config_file}")" '.disallowed_ldap_bind_config=$bindConfig' "${CONFIG_FILE}")
  echo "${updated_config}" > "${CONFIG_FILE}"

  if [[ -n "${DISALLOWED_OVERRIDE_BIND_CONFIG}" ]]; then
    echo "${DISALLOWED_OVERRIDE_BIND_CONFIG}" > "${bind_config_file}"
  else
    echo "" > "${bind_config_file}"
  fi

  updated_config=$(jq --arg bindConfig "$(cat "${bind_config_file}")" '.disallowed_override_bind_config=$bindConfig' "${CONFIG_FILE}")
  echo "${updated_config}" > "${CONFIG_FILE}"

  echo "" > "${bind_config_file}"

  local create_config_file="${PWD}/pats-config/create-config.json"

  if [[ -r "${PWD}/bind-create-config/create-config.json" ]]; then
    cp "${PWD}/bind-create-config/create-config.json" "${create_config_file}"
  elif [[ -n "${CREATE_CONFIG}" ]]; then
    echo "${CREATE_CONFIG}" > "${create_config_file}"
  else
    echo "" > "${create_config_file}"
  fi

  updated_config=$(jq --arg createConfig "$(cat "${create_config_file}")" '.create_config=$createConfig' "${CONFIG_FILE}")
  echo "${updated_config}" > "${CONFIG_FILE}"

  if [[ -n "${CREATE_BOGUS_CONFIG}" ]]; then
    echo "${CREATE_BOGUS_CONFIG}" > "${create_config_file}"
  else
    echo "" > "${create_config_file}"
  fi

  updated_config=$(jq --arg createConfig "$(cat "${create_config_file}")" '.create_bogus_config=$createConfig' "${CONFIG_FILE}")
  echo "${updated_config}" > "${CONFIG_FILE}"

  echo "" > "${create_config_file}"

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