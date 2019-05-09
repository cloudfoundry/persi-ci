#!/bin/bash -eu

echo "${GCP_SERVICE_ACCOUNT_KEY}" | gcloud auth activate-service-account --key-file=-

gcloud beta filestore instances delete "${FILESTORE_INSTANCE_NAME}" \
  --location="${GCP_LOCATION}" \
  --project "${GCP_PROJECT} \
  -q
