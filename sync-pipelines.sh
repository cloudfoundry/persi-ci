#!/bin/bash
set -x

fly -t persi set-pipeline -p keep-pipelines-sync -c <(
cat <<EOF

resources:
- name: persi-ci
  type: git

  source:
    uri: https://github.com/cloudfoundry/persi-ci.git
    branch: freezing

jobs:
- name: reconfigure
  plan:
  - get: persi-ci
    trigger: true
  - set_pipeline: docker-image-build
    file: persi-ci/docker-image-build.yml
    vars: *lastpass_creds
  - set_pipeline: ephemeral-diego
    file: persi-ci/ephemeral-diego.yml
    vars: *lastpass_creds
  - set_pipeline: ephemeral-diego-smb
    file: persi-ci/ephemeral-diego-smb.yml
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
  - set_pipeline: lts-toolsmiths-5.0
    file: persi-ci/lts-toolsmiths.yml
    vars:
      <<: *lastpass_creds
      lts-nfs-branch: v5.0
      mapfs-tag: v1.2.0
      nfs-semver-initial-version: 5.0.3
      pas-version: us_2_8
  - set_pipeline: lts-toolsmiths-2.3
    file: persi-ci/lts-toolsmiths.yml
    vars:
      <<: *lastpass_creds
      lts-nfs-branch: v2.3
      mapfs-tag: v1.2.0
      nfs-semver-initial-version: 2.3.3
      pas-version: us_2_7

EOF
)
