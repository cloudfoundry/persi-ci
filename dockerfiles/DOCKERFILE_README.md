##Dockerfile Notes ##

cfpersi/fork-git-resource:
 - go mod tidy/go mod vendor

cfpersi/bosh-release-tests:
 - has bosh, + ginkgo + go, deploys releases to bosh

cfpersi/mapfs-tests:
 - install golang version from mapfs release, nfs ganesha server, fuse bunch of other stuff
 - used for mapfs unit and fs tests

cfpersi/nfs-integration-tests:
 - has go version from nfs release, install ganesha with an in-memory fs, go modules

cfpersi/nfs-unit-tests:
 - has go version from nfs release and ginkgo

cfpersi/nfs-cats:
 - installs ganesha and exposes ports
 - this image is "cf-push"ed in cats

cfpersi/smb-unit-tests:
 - installs golang release from smb release, ginkgo
