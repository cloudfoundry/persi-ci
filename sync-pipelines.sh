#!/bin/bash
set -x

fly -t volume-services set-pipeline -p keep-pipelines-sync -c <(
cat <<EOF

resources:
- name: persi-ci
  type: git
  source:
    uri: git@github.com:cloudfoundry/persi-ci.git
    branch: master

jobs:
- name: reconfigure
  plan:
  - get: persi-ci
    trigger: true
  - set_pipeline: docker-image-build
    file: persi-ci/docker-image-build.yml
  - set_pipeline: ephemeral-diego
    file: persi-ci/ephemeral-diego.yml
  - set_pipeline: ephemeral-diego-mapfs
    file: persi-ci/ephemeral-diego-mapfs.yml
  - set_pipeline: ephemeral-diego-smb
    file: persi-ci/ephemeral-diego-smb.yml
  - set_pipeline: mapfs
    file: persi-ci/mapfs.yml
  - set_pipeline: nfs-broker
    file: persi-ci/nfs-broker.yml
  - set_pipeline: nfs-driver
    file: persi-ci/nfs-driver.yml
  - set_pipeline: norsk
    file: persi-ci/norsk.yml
  - set_pipeline: shared-units
    file: persi-ci/shared-units.yml
  - set_pipeline: smb-broker
    file: persi-ci/smb-broker.yml
  - set_pipeline: smb-driver
    file: persi-ci/smb-driver.yml
  - set_pipeline: lts-toolsmiths-5.0
    file: persi-ci/lts-toolsmiths.yml
    vars:
      lts-nfs-branch: v5.0
      mapfs-tag: v1.2.0
      nfs-semver-initial-version: 5.0.3
      pas-version: us_2_10
      tas-branch: rel/2.11
  - set_pipeline: lts-toolsmiths-2.3
    file: persi-ci/lts-toolsmiths.yml
    vars:
      lts-nfs-branch: v2.3
      mapfs-tag: v1.2.0
      nfs-semver-initial-version: 2.3.3
      pas-version: us_2_7
      tas-branch: rel/2.7

EOF
)
