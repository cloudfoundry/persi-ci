#!/usr/bin/env bash

set -ex

function get_password_from_credhub() {
  local bosh_manifest_password_variable_name=$1
  credhub find -j -n "${bosh_manifest_password_variable_name}" | jq -r .credentials[].name | xargs credhub get -j -n | jq -r .value
}

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
  "admin_password": "$(get_password_from_credhub cf_admin_password)",
  "admin_user": "${CF_USERNAME}",
  "api": "${CF_API_ENDPOINT}",
  "apps_domain": "${APPS_DOMAIN}",
  "artifacts_directory": "",
  "default_timeout": ${DEFAULT_TIMEOUT},
  "name_prefix": "$(openssl rand -hex 3)",
  "skip_ssl_validation": true,

  "broker_url": "${BROKER_URL}",
  "broker_user": "${BROKER_USER}",
  "isolation_segment": "${TEST_ISOLATION_SEGMENT}",
  "lazy_unmount_remote_server_job_name": "${LAZY_UNMOUNT_REMOTE_SERVER_JOB_NAME}",
  "lazy_unmount_remote_server_process_name": "${LAZY_UNMOUNT_REMOTE_SERVER_PROCESS_NAME}",
  "lazy_unmount_vm_instance": "${LAZY_UNMOUNT_VM_INSTANCE}",
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

  updated_config=$(jq --arg bindConfig "$(cat "${bind_config_file}")" '.bind_config=$bindConfig' "${CONFIG_FILE}")
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

  if [[ -r "${PWD}/lazy-unmount-bind-create-config/bind-config.json" ]]; then
    cp "${PWD}/lazy-unmount-bind-create-config/bind-config.json" "${bind_config_file}"
  elif [[ -n "${BIND_LAZY_UNMOUNT_CONFIG}" ]]; then
    echo "${BIND_LAZY_UNMOUNT_CONFIG}" > "${bind_config_file}"
  else
    echo "" > "${bind_config_file}"
  fi

  updated_config=$(jq --arg bindConfig "$(cat "${bind_config_file}")" '.bind_lazy_unmount_config=$bindConfig' "${CONFIG_FILE}")
  echo "${updated_config}" > "${CONFIG_FILE}"

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

  if [[ -r "${PWD}/lazy-unmount-bind-create-config/create-config.json" ]]; then
    cp "${PWD}/lazy-unmount-bind-create-config/create-config.json" "${create_config_file}"
  elif [[ -n "${CREATE_LAZY_UNMOUNT_CONFIG}" ]]; then
    echo "${CREATE_LAZY_UNMOUNT_CONFIG}" > "${create_config_file}"
  else
    echo "" > "${create_config_file}"
  fi

  updated_config=$(jq --arg createConfig "$(cat "${create_config_file}")" '.create_lazy_unmount_config=$createConfig' "${CONFIG_FILE}")
  echo "${updated_config}" > "${CONFIG_FILE}"

  if [[ -n "${BROKER_PASSWORD_KEY}" ]]; then
    broker_password="$(get_password_from_credhub "${BROKER_PASSWORD_KEY}")"
    updated_config=$(jq ".broker_password=\"${broker_password}\"" "${CONFIG_FILE}")
    echo "${updated_config}" > "${CONFIG_FILE}"
  fi
}

scripts_path="$(dirname "$0")"
source "${scripts_path}/utils.sh"

set +x
"${PWD}/persi-ci/scripts/ci/bbl_get_bosh_env"
source bosh-env/set-env.sh
set -x

validate_required_params
write_config_to_file
