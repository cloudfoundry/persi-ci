function set_cf_admin_password() {
    . <(smith -l smith-env/metadata bosh)
    CF_ADMIN_PASSWORD=$(credhub find -j -n "cf_admin_password" | jq -r '.credentials[].name' | xargs credhub get -j -n | jq -r '.value')
    export CF_ADMIN_PASSWORD
}

function set_cf_api_url() {
    CF_API_ENDPOINT=$(cat smith-env/metadata | jq -r '.cf.api_url')
    export CF_API_ENDPOINT
}

function set_apps_domain() {
    if [ -f "smith-env/name" ]; then
       BOSH_ENV_NAME="$(cat smith-env/name)"
    else
       BOSH_ENV_NAME="$(cat smith-env/metadata | jq -r '.name')"
    fi
    export APPS_DOMAIN="${BOSH_ENV_NAME}.cf-app.com"
}