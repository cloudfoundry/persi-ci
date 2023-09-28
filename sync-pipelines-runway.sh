#!/bin/bash
set -x

fly -t runway-cryogenics set-pipeline -p keep-volume-service-pipelines-sync -c <(
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
#  - set_pipeline: docker-image-build
#    file: persi-ci/docker-image-build.yml
#  - set_pipeline: nfs-volume-release
#    file: persi-ci/nfs-volume-release.yml
#  - set_pipeline: mapfs-release
#    file: persi-ci/mapfs-release.yml
  - set_pipeline: smb-volume-release
    file: persi-ci/smb-volume-release.yml
  - set_pipeline: mapfs
    file: persi-ci/mapfs.yml
  - set_pipeline: nfsbroker
    file: persi-ci/nfsbroker.yml
  - set_pipeline: nfsv3driver
    file: persi-ci/nfsv3driver.yml
#  - set_pipeline: norsk
#    file: persi-ci/norsk.yml
  - set_pipeline: shared-units
    file: persi-ci/shared-units.yml
  - set_pipeline: smbbroker
    file: persi-ci/smbbroker.yml
  - set_pipeline: smbdriver
    file: persi-ci/smbdriver.yml
#  - set_pipeline: lts-nfs-volume-release-v5.0
#    file: persi-ci/lts-nfs-volume-release-v5.0.yml
#    vars:
#      lts-nfs-branch: v5.0
#      mapfs-tag: v1.2.0
#      nfs-semver-initial-version: 5.0.3
#      pas-version: us_2_11_lts2
  - set_pipeline: lts-nfsbroker-v5.0
    file: persi-ci/lts-nfsbroker-v5.0.yml
    vars:
      lts-nfs-branch: v5.0
  - set_pipeline: lts-nfsv3driver-v5.0
    file: persi-ci/lts-nfsv3driver-v5.0.yml
    vars:
      lts-nfs-branch: v5.0
EOF
)
