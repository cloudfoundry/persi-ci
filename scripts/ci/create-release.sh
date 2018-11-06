#!/bin/bash

set -ex

VERSION="$(cat release-version/number)"
TARBALL_NAME="../release-tarball/${RELEASE_NAME}-${VERSION}.tgz"

pushd release
  bosh -n create-release --version="${VERSION}" --tarball="${TARBALL_NAME}" --sha2
popd
