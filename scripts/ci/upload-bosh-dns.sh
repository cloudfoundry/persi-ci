#!/bin/bash -e

pushd "director-state/${BBL_STATE_DIR}"
  eval "$(bbl print-env)"

  bosh_dns_url=$(bosh runtime-config --name=dns | grep bosh-dns-release | awk '{print $2}')

  bosh upload-release -n ${bosh_dns_url}

popd
