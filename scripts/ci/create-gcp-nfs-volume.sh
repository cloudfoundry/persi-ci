#!/bin/bash -eu

apt-get install -y jq python3-pip nfs-common
pip3 install yq

echo "${GCP_SERVICE_ACCOUNT_KEY}" | gcloud auth activate-service-account --key-file=-

echo "Creating GCP filestore volume..."
# shellcheck disable=SC2140
gcloud beta filestore instances create "${FILESTORE_INSTANCE_NAME}" \
  --project "${GCP_PROJECT}" \
  --location="${GCP_LOCATION}" \
  --tier=STANDARD \
  --file-share=name="${FILESHARE_NAME}",capacity=1TB \
  --network=name="${NETWORK_NAME}",reserved-ip-range="10.1.0.0/29"

VOLUME_IP_ADDRESS="$(gcloud beta filestore instances describe "${FILESTORE_INSTANCE_NAME}" --location="${GCP_LOCATION}" | yq -r '.networks[0].ipAddresses[0]')"

echo "nfs://${VOLUME_IP_ADDRESS}/${FILESHARE_NAME}" > gcp-nfs-volume-info/fuse-nfs-volume-info
echo "${VOLUME_IP_ADDRESS}:/${FILESHARE_NAME}" > gcp-nfs-volume-info/nfs-volume-info

echo "Modifying volume permissions..."
MOUNT_DIR="/tmp/mount_dir"
mkdir -p "${MOUNT_DIR}"

mount -t nfs -o nolock "${VOLUME_IP_ADDRESS}:/${FILESHARE_NAME}" "${MOUNT_DIR}"
chmod 0777 "${MOUNT_DIR}"
umount "${MOUNT_DIR}"
