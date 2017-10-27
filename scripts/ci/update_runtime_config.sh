#!/usr/bin/env bash

cat > runtime-config-out/addons.yml << EOF
---
releases:
- name: cephfs
  version: TBD
addons:
- name: voldrivers
  include:
    deployments: [persi-cf-diego]
    jobs: [{name: rep, release: diego}]
  jobs:
  - name: cephdriver
    release: cephfs
    properties: {}
EOF