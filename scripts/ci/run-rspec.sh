#!/bin/bash

set -eux

pushd test-repo > /dev/null
  gem install bundler
  bundle install
  bundle exec rspec
popd > /dev/null
