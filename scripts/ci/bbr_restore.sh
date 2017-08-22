#!/bin/bash -eu

bosh recreate #TODO: recreate proper
source bosh-env/set-env.sh

export CA_CERT="$PWD/bosh-env/ca-cert.pem"
export BBR_PRIVATE_KEY=$(cat bosh-env/ssh-key)

pushd restore-artifact
  nohup ../binary/bbr deployment --target "${BOSH_ENVIRONMENT}" \
  --username "${BOSH_CLIENT}" \
  --deployment "${DEPLOYMENT_NAME}" \
  restore \
    --artifact-path backup-artifact/*
popd

