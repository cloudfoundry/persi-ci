#!/bin/bash

set -x -e

function finish {
    echo "Cleaning up..."
    cf delete nfs-migration-test-app -f
    cf delete-service nfs-migration-test-service -f
    cf delete-service-broker nfs-broker-migration-test -f
}
trap finish EXIT


bbl --state-dir bbl-state/${BBL_STATE_DIR} print-env > set-env.sh
source set-env.sh

if [ -z "$CF_PASSWORD" ]; then
    if [ -e "vars-store/deployment-vars.yml" ]; then
        CF_PASSWORD=`grep cf_admin_password vars-store/deployment-vars.yml | awk  '{print $2}'`
    fi
fi
if [ -z "$BROKER_PASSWORD" ]; then
    if [ -e "vars-store/deployment-vars.yml" ]; then
        BROKER_PASSWORD=`grep $BROKER_PASSWORD_KEY vars-store/deployment-vars.yml | awk  '{print $2}'`
    fi
fi

echo "Running errand nfs-broker-migration-test-mysql-push..."
bosh -n -d cf run-errand nfs-broker-migration-test-mysql-push

echo "Logging in with cf CLI..."
cf api $CF_API_ENDPOINT --skip-ssl-validation
cf auth $CF_USER "$CF_PASSWORD"
cf create-org $CF_ORG
cf target -o $CF_ORG
cf create-space $CF_SPACE
cf target -s $CF_SPACE

echo "Creating service broker..."
cf create-service-broker $SERVICE_BROKER_NAME $BROKER_USERNAME $BROKER_PASSWORD $BROKER_APP_URL

echo "Validating service broker is in the list..."
cf service-brokers | grep $SERVICE_BROKER_NAME

echo "Enabling service access..."
cf enable-service-access nfs-migration-test-mysql -o $CF_ORG

echo "Validating service access..."
cf service-access | grep nfs-migration-test-mysql

echo "Creating service..."
cf create-service nfs-migration-test-mysql Existing nfs-migration-test-service -c ${CREATE_CONFIG}

echo "Pushing app..."
cd nfs-volume-release/src/code.cloudfoundry.org/persi-acceptance-tests/assets/pora
cf push nfs-migration-test-app --no-start

echo "Binding service..."
cf bind-service nfs-migration-test-app nfs-migration-test-service -c ${BIND_CONFIG}

echo "Starting app..."
cf start nfs-migration-test-app

echo "Validating bound service..."
cf services | grep nfs-migration-test-service | grep nfs-migration-test-app

echo "Running errand migrate-mysql-to-credhub-test-migration..."
bosh -n -d cf run-errand migrate-mysql-to-credhub-test-migration

echo "Running errand nfs-broker-migration-test-credhub-push..."
bosh -n -d cf run-errand nfs-broker-migration-test-credhub-push

echo "Validating bound service..."
cf services | grep nfs-migration-test-service | grep nfs-migration-test-app

echo "Unbinding service..."
cf unbind-service nfs-migration-test-app nfs-migration-test-service

echo "Binding service..."
cf bind-service nfs-migration-test-app nfs-migration-test-service -c ${BIND_CONFIG}
