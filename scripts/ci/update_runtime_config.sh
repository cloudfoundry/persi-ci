#!/usr/bin/env bash

cat > runtime-config-out/addons.yml << EOF
---
releases:
- name: local-volume
  version: TBD
- name: cephfs
  version: TBD
- name: efs-volume
  version: TBD
- name: nfs-volume
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
  - name: efsdriver
    release: efs-volume
    properties: {}
  - name: nfsv3driver
    release: nfs-volume
    properties:
      ldap_svc_user: ${LDAP_SVC_USER}
      ldap_svc_password: ${LDAP_SVC_PASS}
      ldap_host: ${LDAP_HOST}
      ldap_port: ${LDAP_PORT}
      ldap_proto: ${LDAP_PROTO}
      ldap_user_fqdn: ${LDAP_USER_FQDN}
EOF