#!/bin/bash

pushd csi-spec
  go get -u github.com/golang/protobuf/{proto,protoc-gen-go}
  export PATH=$PATH:$HOME/src/go/bin
  make csi.proto
  make csi.pb.go
  mv csi.pb.go ../created-csi-proto
popd

