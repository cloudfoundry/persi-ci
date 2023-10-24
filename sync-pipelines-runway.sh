#!/bin/bash
set -x

fly -t runway set-pipeline -p keep-volume-service-pipelines-sync -c <(
cat <<EOF

#! this needs to come first, else all other vars can't be resolved.
#! cerberus creds are required to access the teams vault instance managed by cerberus. The creds have been created manually via the vault-cli targetting the teams cerberus vault. Example steps to create an approle are here: https://developer.hashicorp.com/vault/docs/auth/approle the required value for policies is `restricted-admin` the auth method is mounted on the standard path.
cerberus: &cerberus
  role_id: ((cerberus-auth.role_id))
  secret_id: ((cerberus-auth.secret_id))
cerberus_url: &cerberus_url ((cerberus-auth.url))
github_ssh_key: &github_ssh_key ((cerberus:github.ssh_key))

var_sources:
- name: cerberus
  type: vault
  config:
    auth_backend: approle
    auth_params: *cerberus
    url: *cerberus_url
    path_prefix: secret
resources:
- name: persi-ci
  type: git
  source:
    uri: https://github.com/cloudfoundry/persi-ci.git
    branch: master

- name: cryogenics-concourse-tasks
  type: git
  icon: github
  source:
    uri: git@github.com:pivotal/cryogenics-concourse-tasks.git
    private_key: *github_ssh_key

- name: cryogenics-essentials
  type: registry-image
  source:
    repository: cryogenics/essentials
    registry_mirror:
      host: harbor-repo.vmware.com
jobs:
- name: reset-docker-image-build
  plan:
  - in_parallel:
    - get: persi-ci
      trigger: true
    - get: cryogenics-concourse-tasks
    - get: cryogenics-essentials
  - task: check-pipeline-for-stray-secrets
    image: cryogenics-essentials
    file: cryogenics-concourse-tasks/pipeline-linting/check-pipeline-for-stray-secrets/task.yml
    input_mapping:
      cryogenics-concourse-tasks: cryogenics-concourse-tasks
      pipeline-repo: persi-ci
    params:
      PIPELINE_TO_CHECK: ./pipeline-repo/docker-image-build.yml
  - set_pipeline: volume-services-docker-image-build
    file: persi-ci/docker-image-build.yml
- name: reset-nfs-volume-release
  plan:
  - in_parallel:
    - get: persi-ci
      trigger: true
    - get: cryogenics-concourse-tasks
    - get: cryogenics-essentials
  - task: check-pipeline-for-stray-secrets
    image: cryogenics-essentials
    file: cryogenics-concourse-tasks/pipeline-linting/check-pipeline-for-stray-secrets/task.yml
    input_mapping:
      cryogenics-concourse-tasks: cryogenics-concourse-tasks
      pipeline-repo: persi-ci
    params:
      PIPELINE_TO_CHECK: ./pipeline-repo/nfs-volume-release.yml
  - set_pipeline: nfs-volume-release
    file: persi-ci/nfs-volume-release.yml
- name: reset-mapfs-release
  plan:
  - in_parallel:
    - get: persi-ci
      trigger: true
    - get: cryogenics-concourse-tasks
    - get: cryogenics-essentials
  - task: check-pipeline-for-stray-secrets
    image: cryogenics-essentials
    file: cryogenics-concourse-tasks/pipeline-linting/check-pipeline-for-stray-secrets/task.yml
    input_mapping:
      cryogenics-concourse-tasks: cryogenics-concourse-tasks
      pipeline-repo: persi-ci
    params:
      PIPELINE_TO_CHECK: ./pipeline-repo/mapfs-release.yml
  - set_pipeline: mapfs-release
    file: persi-ci/mapfs-release.yml
- name: reset-smb-volume-release
  plan:
  - in_parallel:
    - get: persi-ci
      trigger: true
    - get: cryogenics-concourse-tasks
    - get: cryogenics-essentials
  - task: check-pipeline-for-stray-secrets
    image: cryogenics-essentials
    file: cryogenics-concourse-tasks/pipeline-linting/check-pipeline-for-stray-secrets/task.yml
    input_mapping:
      cryogenics-concourse-tasks: cryogenics-concourse-tasks
      pipeline-repo: persi-ci
    params:
      PIPELINE_TO_CHECK: ./pipeline-repo/smb-volume-release.yml
  - set_pipeline: smb-volume-release
    file: persi-ci/smb-volume-release.yml
- name: reset-mapfs
  plan:
  - in_parallel:
    - get: persi-ci
      trigger: true
    - get: cryogenics-concourse-tasks
    - get: cryogenics-essentials
  - task: check-pipeline-for-stray-secrets
    image: cryogenics-essentials
    file: cryogenics-concourse-tasks/pipeline-linting/check-pipeline-for-stray-secrets/task.yml
    input_mapping:
      cryogenics-concourse-tasks: cryogenics-concourse-tasks
      pipeline-repo: persi-ci
    params:
      PIPELINE_TO_CHECK: ./pipeline-repo/mapfs.yml
  - set_pipeline: mapfs
    file: persi-ci/mapfs.yml
- name: reset-nfsbroker
  plan:
  - in_parallel:
    - get: persi-ci
      trigger: true
    - get: cryogenics-concourse-tasks
    - get: cryogenics-essentials
  - task: check-pipeline-for-stray-secrets
    image: cryogenics-essentials
    file: cryogenics-concourse-tasks/pipeline-linting/check-pipeline-for-stray-secrets/task.yml
    input_mapping:
      cryogenics-concourse-tasks: cryogenics-concourse-tasks
      pipeline-repo: persi-ci
    params:
      PIPELINE_TO_CHECK: ./pipeline-repo/nfsbroker.yml
  - set_pipeline: nfsbroker
    file: persi-ci/nfsbroker.yml
- name: reset-nfsv3driver
  plan:
  - in_parallel:
    - get: persi-ci
      trigger: true
    - get: cryogenics-concourse-tasks
    - get: cryogenics-essentials
  - task: check-pipeline-for-stray-secrets
    image: cryogenics-essentials
    file: cryogenics-concourse-tasks/pipeline-linting/check-pipeline-for-stray-secrets/task.yml
    input_mapping:
      cryogenics-concourse-tasks: cryogenics-concourse-tasks
      pipeline-repo: persi-ci
    params:
      PIPELINE_TO_CHECK: ./pipeline-repo/nfsv3driver.yml
  - set_pipeline: nfsv3driver
    file: persi-ci/nfsv3driver.yml
- name: reset-shared-units
  plan:
  - in_parallel:
    - get: persi-ci
      trigger: true
    - get: cryogenics-concourse-tasks
    - get: cryogenics-essentials
  - task: check-pipeline-for-stray-secrets
    image: cryogenics-essentials
    file: cryogenics-concourse-tasks/pipeline-linting/check-pipeline-for-stray-secrets/task.yml
    input_mapping:
      cryogenics-concourse-tasks: cryogenics-concourse-tasks
      pipeline-repo: persi-ci
    params:
      PIPELINE_TO_CHECK: ./pipeline-repo/shared-units.yml
  - set_pipeline: shared-units
    file: persi-ci/shared-units.yml
- name: reset-smbbroker
  plan:
  - in_parallel:
    - get: persi-ci
      trigger: true
    - get: cryogenics-concourse-tasks
    - get: cryogenics-essentials
  - task: check-pipeline-for-stray-secrets
    image: cryogenics-essentials
    file: cryogenics-concourse-tasks/pipeline-linting/check-pipeline-for-stray-secrets/task.yml
    input_mapping:
      cryogenics-concourse-tasks: cryogenics-concourse-tasks
      pipeline-repo: persi-ci
    params:
      PIPELINE_TO_CHECK: ./pipeline-repo/smbbroker.yml
  - set_pipeline: smbbroker
    file: persi-ci/smbbroker.yml
- name: reset-smbdriver
  plan:
  - in_parallel:
    - get: persi-ci
      trigger: true
    - get: cryogenics-concourse-tasks
    - get: cryogenics-essentials
  - task: check-pipeline-for-stray-secrets
    image: cryogenics-essentials
    file: cryogenics-concourse-tasks/pipeline-linting/check-pipeline-for-stray-secrets/task.yml
    input_mapping:
      cryogenics-concourse-tasks: cryogenics-concourse-tasks
      pipeline-repo: persi-ci
    params:
      PIPELINE_TO_CHECK: ./pipeline-repo/smbdriver.yml
  - set_pipeline: smbdriver
    file: persi-ci/smbdriver.yml
- name: reset-lts-nfs-volume-release-v5.0
  plan:
  - in_parallel:
    - get: persi-ci
      trigger: true
    - get: cryogenics-concourse-tasks
    - get: cryogenics-essentials
  - task: check-pipeline-for-stray-secrets
    image: cryogenics-essentials
    file: cryogenics-concourse-tasks/pipeline-linting/check-pipeline-for-stray-secrets/task.yml
    input_mapping:
      cryogenics-concourse-tasks: cryogenics-concourse-tasks
      pipeline-repo: persi-ci
    params:
      PIPELINE_TO_CHECK: ./pipeline-repo/lts-nfs-volume-release-v5.0.yml
  - set_pipeline: lts-nfs-volume-release-v5.0
    file: persi-ci/lts-nfs-volume-release-v5.0.yml
    vars:
      lts-nfs-branch: v5.0
      nfs-semver-initial-version: 5.0.3
      pas-pool-name: tas-2_11
- name: reset-lts-nfsbroker-v5.0
  plan:
  - in_parallel:
    - get: persi-ci
      trigger: true
    - get: cryogenics-concourse-tasks
    - get: cryogenics-essentials
  - task: check-pipeline-for-stray-secrets
    image: cryogenics-essentials
    file: cryogenics-concourse-tasks/pipeline-linting/check-pipeline-for-stray-secrets/task.yml
    input_mapping:
      cryogenics-concourse-tasks: cryogenics-concourse-tasks
      pipeline-repo: persi-ci
    params:
      PIPELINE_TO_CHECK: ./pipeline-repo/lts-nfsbroker-v5.0.yml
  - set_pipeline: lts-nfsbroker-v5.0
    file: persi-ci/lts-nfsbroker-v5.0.yml
    vars:
      lts-nfs-branch: v5.0
- name: reset-lts-nfsv3driver-v5.0
  plan:
  - in_parallel:
    - get: persi-ci
      trigger: true
    - get: cryogenics-concourse-tasks
    - get: cryogenics-essentials
  - task: check-pipeline-for-stray-secrets
    image: cryogenics-essentials
    file: cryogenics-concourse-tasks/pipeline-linting/check-pipeline-for-stray-secrets/task.yml
    input_mapping:
      cryogenics-concourse-tasks: cryogenics-concourse-tasks
      pipeline-repo: persi-ci
    params:
      PIPELINE_TO_CHECK: ./pipeline-repo/lts-nfsv3driver-v5.0.yml
  - set_pipeline: lts-nfsv3driver-v5.0
    file: persi-ci/lts-nfsv3driver-v5.0.yml
    vars:
      lts-nfs-branch: v5.0
EOF
)
