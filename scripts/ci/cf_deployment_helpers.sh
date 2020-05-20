function set_cf_admin_password() {
    BOSH_ENV_NAME=$(cat smith-env/name)
    eval "$(smith -e $BOSH_ENV_NAME bosh)"
    export CF_ADMIN_PASSWORD=$(credhub find -j -n "cf_admin_password" | jq -r '.credentials[].name' | xargs credhub get -j -n | jq -r '.value')
}

function set_cf_api_url() {
    export CF_API_ENDPOINT=$(cat smith-env/metadata | jq -r '.cf.api_url')
}

function set_apps_domain() {
    BOSH_ENV_NAME=$(cat smith-env/name)
    export APPS_DOMAIN="${BOSH_ENV_NAME}.cf-app.com"
}