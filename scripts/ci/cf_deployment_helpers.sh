function set_cf_admin_password() {
    eval "$(smith -l smith-env/metadata bosh)"
    CF_ADMIN_PASSWORD=$(credhub find -j -n "cf_admin_password" | jq -r '.credentials[].name' | xargs credhub get -j -n | jq -r '.value')
    export CF_ADMIN_PASSWORD
}

function set_cf_api_url() {
    CF_API_ENDPOINT=$(cat smith-env/metadata | jq -r '.cf.api_url')
    export CF_API_ENDPOINT
}

function set_apps_domain() {
    APPS_DOMAIN="$(jq -r '.cf.api_url | capture("^api\\.(?<system_domain>.*)$") | .system_domain' smith-env/metadata)"
    export APPS_DOMAIN
}
