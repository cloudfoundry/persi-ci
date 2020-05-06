function set_cf_admin_password() {
    set +x
    source "${PWD}/persi-ci/scripts/ci/bbl_get_bosh_env"
    source bosh-env/set-env.sh
    set -x
    export CF_ADMIN_PASSWORD=$(get_password_from_credhub cf_admin_password)
}

function set_cf_api_url() {
    set +x
    source "${PWD}/persi-ci/scripts/ci/bbl_get_bosh_env"
    source bosh-env/set-env.sh
    set -x
    export CF_API_ENDPOINT="api.${ENV}.cf-app.com"
}

function set_apps_domain() {
    set +x
    source "${PWD}/persi-ci/scripts/ci/bbl_get_bosh_env"
    source bosh-env/set-env.sh
    set -x
    export APPS_DOMAIN="${ENV}.cf-app.com"
}