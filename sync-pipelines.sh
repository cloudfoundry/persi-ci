#!/bin/bash
set -x

fly -t volume-services set-pipeline -p keep-pipelines-sync -c <(
cat <<EOF

resources:
- name: persi-ci
  type: git
  source:
    uri: https://github.com/cloudfoundry/persi-ci.git
    branch: master

jobs:
- name: reconfigure
  plan:
  - get: persi-ci
    trigger: true
  - set_pipeline: nfs-volume-release
    file: persi-ci/nfs-volume-release.yml
  - set_pipeline: norsk
    file: persi-ci/norsk.yml
  - set_pipeline: lts-nfs-volume-release-v5.0
    file: persi-ci/lts-nfs-volume-release-v5.0.yml
    vars:
      lts-nfs-branch: v5.0
      mapfs-tag: v1.2.0
      nfs-semver-initial-version: 5.0.3
      pas-version: us_2_11_lts2

EOF
)
