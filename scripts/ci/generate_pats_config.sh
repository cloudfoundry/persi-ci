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
  local bind_config_file="${PWD}/pats-config/bind-config.json"

  if [[ -r "${PWD}/bind-create-config/bind-config.json" ]]; then
    cp "${PWD}/bind-create-config/bind-config.json" "${bind_config_file}"
  elif [[ -n "${BIND_CONFIG}" ]]; then
    echo "${BIND_CONFIG}" > "${bind_config_file}"
  else
    bind_config_file=""
  fi

  local create_config_file="${PWD}/pats-config/create-config.json"

  if [[ -r "${PWD}/bind-create-config/create-config.json" ]]; then
    cp "${PWD}/bind-create-config/create-config.json" "${create_config_file}"
  elif [[ -n "${CREATE_CONFIG}" ]]; then
    echo "${CREATE_CONFIG}" > "${create_config_file}"
  else
    create_config_file=""
  fi

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

  "bind_bogus_config": "${BIND_BOGUS_CONFIG}",
  "bind_config": "${bind_config_file}",
  "broker_url": "${BROKER_URL}",
  "broker_user": "${BROKER_USER}",
  "create_bogus_config": "${CREATE_BOGUS_CONFIG}",
  "create_config": "${create_config_file}",
  "create_lazy_unmount_config": "${CREATE_LAZY_UNMOUNT_CONFIG}",
  "disallowed_ldap_bind_config": "${DISALLOWED_LDAP_BIND_CONFIG}",
  "isolation_segment": "${TEST_ISOLATION_SEGMENT}",
  "lazy_unmount_vm_instance": "${LAZY_UNMOUNT_VM_INSTANCE}",
  "plan_name": "${PLAN_NAME}",
  "service_name": "${SERVICE_NAME}"
}
EOF

  if [[ -n "${BROKER_PASSWORD_KEY}" ]]; then
    broker_password="$(get_password_from_credhub "${BROKER_PASSWORD_KEY}")"
    new_config=$(cat "${CONFIG_FILE}" | jq ".broker_password=\"${broker_password}\"")
    echo "${new_config}" > "${CONFIG_FILE}"
  fi
}

scripts_path="$(dirname $0)"
source "${scripts_path}/utils.sh"

set +x
${PWD}/persi-ci/scripts/ci/bbl_get_bosh_env
source bosh-env/set-env.sh
set -x

validate_required_params
write_config_to_file
