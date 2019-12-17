#!/bin/bash

set -e

echo ${GOOGLE_SERVICE_KEY} > /tmp/key.json
gcloud auth activate-service-account --key-file=/tmp/key.json

gcloud config set project cff-diego-persistence
gcloud config set compute/zone ${GOOGLE_ZONE}

. ./eirini-env/${EIRINI_ENV_DIR}/envs.sh

gcloud container clusters get-credentials $ENV_NAME

until cf api api.$EIRINI_DOMAIN --skip-ssl-validation; do sleep 5; done
