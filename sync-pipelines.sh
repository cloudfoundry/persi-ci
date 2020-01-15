#!/bin/bash
set -x

LPASS_CREDS=`lpass show --note pipeline-secrets|sed -e 's/^/  /'`

fly -t persi set-pipeline -p keep-pipelines-sync -c <(
cat <<EOF
vars: &lastpass_creds
$LPASS_CREDS

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
  - set_pipeline: lts-1.7
    file: persi-ci/lts-1-7.yml
    vars:
      <<: *lastpass_creds
      lts-nfs-branch: v1.7
      mapfs-tag: v1.2.0
      cf-d-version-tag: v7.5.0
      nfs-semver-initial-version: 1.7.13
      cf-d-tasks-version-tag: v10.9.0
      nfs-volume-release-tarball-regexp: "nfs-volume-(1.7.*).tgz"
  - set_pipeline: lts-2.3
    file: persi-ci/lts.yml
    vars:
      <<: *lastpass_creds
      lts-nfs-branch: v2.3
      mapfs-tag: v1.2.0
      cf-d-version-tag: v12.1.0
      nfs-semver-initial-version: 2.3.3
      cf-d-tasks-version-tag: v10.9.0
      nfs-volume-release-tarball-regexp: "nfs-volume-(2.3.*).tgz"
  - set_pipeline: lts-5.0
    file: persi-ci/lts.yml
    vars:
      <<: *lastpass_creds
      lts-nfs-branch: v5.0
      mapfs-tag: v1.2.0
      cf-d-version-tag: v12.7.0
      nfs-semver-initial-version: 5.0.3
      cf-d-tasks-version-tag: v10.9.0
      nfs-volume-release-tarball-regexp: "nfs-volume-(5.0.*).tgz"
EOF
)
