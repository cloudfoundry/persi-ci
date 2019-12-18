#!/bin/bash

set -ex
#set -x

export MZ_NAME=${ENV_NAME}
export DNS_NAME=${ENV_NAME}-dns

pushd helmfile-eirini

    mkdir ./envs/${ENV_NAME}
    cp -R ../eirini-env/${EIRINI_ENV_DIR}/* ./envs/${ENV_NAME}

    echo ${GOOGLE_SERVICE_KEY} > /tmp/key.json
    gcloud auth activate-service-account --key-file=/tmp/key.json

    gcloud config set project cff-diego-persistence
    gcloud config set compute/zone ${GOOGLE_ZONE}

    . ./envs/${ENV_NAME}/envs.sh

    if ! gcloud container clusters describe ${ENV_NAME}; then
        gcloud container clusters create $ENV_NAME --num-nodes 5

        gcloud container clusters get-credentials $ENV_NAME

        gcloud dns managed-zones create ${MZ_NAME} \
          --dns-name $EXTERNAL_DNS_DOMAIN \
          --description "Managed zone for ${ENV_NAME}"

        gcloud iam service-accounts create \
        ${DNS_NAME} --display-name "DNS Management for ${ENV_NAME}"

        gcloud projects add-iam-policy-binding ${GOOGLE_PROJECT_ID} \
        --member serviceAccount:${CERT_MANAGER_EMAIL} --role roles/dns.admin

        gcloud iam service-accounts keys create \
        ${GOOGLE_APPLICATION_CREDENTIALS_FILE} --iam-account=$CERT_MANAGER_EMAIL

    fi
    . ./envs/${ENV_NAME}/envs.sh

    kubectl -n kube-system create serviceaccount tiller
    kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
    helm init --service-account=tiller
    kubectl -n kube-system delete service tiller-deploy
    kubectl -n kube-system patch deployment tiller-deploy --patch '
spec:
  template:
    spec:
      containers:
        - name: tiller
          ports: []
          command: ["/tiller"]
          args: ["--listen=localhost:44134"]
'

    until helm version | grep Server; do sleep 1; done

    kubectl apply --validate=false -f resources/cert-manager/crds.yaml

    until helmfile --state-values-file ${ENV_DIR}values.yaml diff; do sleep 1; done
    helmfile --state-values-file ${ENV_DIR}values.yaml apply

    mkdir -p ../updated-eirini-env
    shopt -s dotglob
    cp -R ../eirini-env/* ../updated-eirini-env/
    cp -R ./envs/${ENV_NAME}/* ../updated-eirini-env/${EIRINI_ENV_DIR}/

popd


pushd ./updated-eirini-env/
    git config user.email "${GIT_EMAIL}"
    git config user.name "${GIT_USER}"

    git add -A .
    git commit -m "Update eirini env [ci skip]"
popd