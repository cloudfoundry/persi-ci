#!/bin/bash

set -eux

pushd test-repo > /dev/null
  bundle update --bundler
  bundle install
  bundle exec rspec
popd > /dev/null
