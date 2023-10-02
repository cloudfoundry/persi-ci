function set_cf_admin_password() {
    CF_ADMIN_PASSWORD=$(credhub find -j -n "cf_admin_password" | jq -r '.credentials[].name' | xargs credhub get -j -n | jq -r '.value')
    export CF_ADMIN_PASSWORD
}

function set_cf_api_url() {
    CF_API_ENDPOINT=$(jq -r '.cf.api_url' smith-env/metadata)
    export CF_API_ENDPOINT
}

function set_apps_domain() {
    BOSH_ENV_NAME=$(jq -r '.name' smith-env/metadata)
    APPS_DOMAIN="${BOSH_ENV_NAME}.cf-app.com"
    export APPS_DOMAIN
}