#!/usr/bin/env bash

set -ex

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
  "name_prefix": "$(openssl rand -hex 3)",
  "skip_ssl_validation": true,

  "broker_url": "${BROKER_URL}",
  "broker_user": "${BROKER_USER}",
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

  updated_config=$(jq ".broker_password=\"${BROKER_PASSWORD}\"" "${CONFIG_FILE}")
  echo "${updated_config}" > "${CONFIG_FILE}"
}

set_cf_admin_password
set_cf_api_url
set_apps_domain
validate_required_params
write_config_to_file
