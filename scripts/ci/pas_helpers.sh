function set_cf_admin_password() {
  BOSH_ENV_NAME=$(cat smith-env/name)
  export env=$BOSH_ENV_NAME
  eval "$(smith -e $BOSH_ENV_NAME bosh)"
  export CF_ADMIN_PASSWORD=$(credhub find -j -n "uaa/admin_credentials" | jq -r '.credentials[].name' | xargs credhub get -j -n | jq -r '.value.password')
}

function set_cf_api_url() {
  SYSTEM_DOMAIN=$(cat smith-env/metadata | jq -r '.sys_domain')
  export CF_API_ENDPOINT="api.${SYSTEM_DOMAIN}"
}

function set_apps_domain() {
    export APPS_DOMAIN=$(cat smith-env/metadata | jq -r '.apps_domain')
}
