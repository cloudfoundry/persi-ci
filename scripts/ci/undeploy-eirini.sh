#!/bin/bash

set -x

echo ${GOOGLE_SERVICE_KEY} > /tmp/key.json
gcloud auth activate-service-account --key-file=/tmp/key.json

gcloud config set project cff-diego-persistence
gcloud config set compute/zone ${GOOGLE_ZONE}



DNS_NAME=${ENV_NAME}-dns
EMAIL=${DNS_NAME}@$GOOGLE_PROJECT_ID.iam.gserviceaccount.com

gcloud projects remove-iam-policy-binding ${GOOGLE_PROJECT_ID} \
--member serviceAccount:${EMAIL} --role roles/dns.admin

gcloud iam service-accounts delete ${EMAIL} --quiet

MZ_NAME=${ENV_NAME}
touch empty-file
gcloud dns record-sets import -z ${MZ_NAME} --delete-all-existing empty-file
gcloud dns managed-zones delete ${MZ_NAME} --quiet

gcloud container clusters delete ${ENV_NAME} --quiet

