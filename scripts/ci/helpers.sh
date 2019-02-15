function get_password_from_credhub() {
  local bosh_manifest_password_variable_name=$1
  credhub find -j -n "${bosh_manifest_password_variable_name}" | jq -r .credentials[].name | xargs credhub get -j -n | jq -r .value
}
