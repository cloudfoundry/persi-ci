#!/bin/bash
set -x

fly -t persi set-pipeline -p reconfigure -c <(
cat <<EOF
vars: &lastpass_creds
`lpass show --note pipeline-secrets|sed -e 's/^/  /'`

resources:
- name: persi-ci
  type: git
  source:
    uri: https://github.com/cloudfoundry/persi-ci.git

jobs:
- name: reconfigure
  plan:
  - get: persi-ci
    trigger: true
  - set_pipeline: cf-volume-services-diego
    file: persi-ci/cf-volume-services-diego.yml
    vars: *lastpass_creds
  - set_pipeline: cf-volume-services-k8s
    file: persi-ci/cf-volume-services-k8s.yml
    vars: *lastpass_creds
  - set_pipeline: docker-image-build
    file: persi-ci/docker-image-build.yml
    vars: *lastpass_creds
  - set_pipeline: ephemeral-diego
    file: persi-ci/ephemeral-diego.yml
    vars: *lastpass_creds
  - set_pipeline: mapfs
    file: persi-ci/mapfs.yml
    vars: *lastpass_creds
  - set_pipeline: nfs-broker
    file: persi-ci/nfs-broker.yml
    vars: *lastpass_creds
  - set_pipeline: nfs-driver
    file: persi-ci/nfs-driver.yml
    vars: *lastpass_creds
  - set_pipeline: norsk
    file: persi-ci/norsk.yml
    vars: *lastpass_creds
  - set_pipeline: shared-units
    file: persi-ci/shared-units.yml
    vars: *lastpass_creds
  - set_pipeline: smb-broker
    file: persi-ci/smb-broker.yml
    vars: *lastpass_creds
  - set_pipeline: smb-driver
    file: persi-ci/smb-driver.yml
    vars: *lastpass_creds
EOF
)
