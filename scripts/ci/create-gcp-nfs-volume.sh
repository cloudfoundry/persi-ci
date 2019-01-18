#!/bin/bash -eu

apt-get install -y jq python3-pip
pip3 install yq

echo "${GCP_SERVICE_ACCOUNT_KEY}" | gcloud auth activate-service-account --key-file=-

# shellcheck disable=SC2140
gcloud beta filestore instances create "${FILESTORE_INSTANCE_NAME}" \
  --location="${GCP_LOCATION}" \
  --tier=STANDARD \
  --file-share=name="${FILESHARE_NAME}",capacity=1TB \
  --network=name="${NETWORK_NAME}",reserved-ip-range="10.1.0.0/29"

VOLUME_IP_ADDRESS="$(gcloud beta filestore instances describe "${FILESTORE_INSTANCE_NAME}" --location="${GCP_LOCATION}" | yq -r '.networks[0].ipAddresses[0]')"

echo "${VOLUME_IP_ADDRESS}:/${FILESHARE_NAME}" > gcp-nfs-volume-info/volume-info
