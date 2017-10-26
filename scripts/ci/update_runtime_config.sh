#!/usr/bin/env bash

cat > runtime-config-out/addons.yml << EOF
---
releases:
- name: local-volume
  version: TBD
- name: cephfs
  version: TBD
addons:
- name: voldrivers
  include:
    deployments: [persi-cf-diego]
    jobs: [{name: rep, release: diego}]
  jobs:
  - name: localdriver
    release: local-volume
    properties: {}
  - name: cephdriver
    release: cephfs
    properties: {}
EOF