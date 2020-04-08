function set_cf_admin_password() {
    export CF_ADMIN_PASSWORD=$(cat cluster-info/cf-values.yml | yq -r .cf_admin_password)
}

function set_cf_api_url() {
    system_domain=$(cat cluster-info/cf-values.yml | yq -r '.system_domain')
    export CF_API_ENDPOINT="api.${system_domain}"
}

function set_apps_domain() {
    export APPS_DOMAIN=$(cat cluster-info/cf-values.yml | yq -r '.app_domains[0]')
}
