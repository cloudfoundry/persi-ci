function set_cf_admin_password() {
  eval "$(smith bosh -l smith-env/metadata)"
  CF_ADMIN_PASSWORD=$(credhub find -j -n "uaa/admin_credentials" | jq -r '.credentials[].name' | xargs credhub get -j -n | jq -r '.value.password')
  export CF_ADMIN_PASSWORD
}

function set_cf_api_url() {
  SYSTEM_DOMAIN=$(jq -r '.sys_domain' smith-env/metadata)
  CF_API_ENDPOINT="api.${SYSTEM_DOMAIN}"
  export CF_API_ENDPOINT
}

function set_apps_domain() {
    APPS_DOMAIN=$(jq -r '.apps_domain' smith-env/metadata)
    export APPS_DOMAIN
}
