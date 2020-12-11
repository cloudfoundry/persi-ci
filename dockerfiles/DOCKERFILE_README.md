##Dockerfile Notes ##

harbor-repo.vmware.com/dockerhub-proxy-cache/cfpersi/fork-git-resource:
 - go mod tidy/go mod vendor

harbor-repo.vmware.com/dockerhub-proxy-cache/cfpersi/bosh-release-tests:
 - has bosh, + ginkgo + go, deploys releases to bosh

harbor-repo.vmware.com/dockerhub-proxy-cache/cfpersi/mapfs-tests:
 - install golang version from mapfs release, nfs ganesha server, fuse bunch of other stuff
 - used for mapfs unit and fs tests

harbor-repo.vmware.com/dockerhub-proxy-cache/cfpersi/nfs-integration-tests:
 - has go version from nfs release, install ganesha with an in-memory fs, go modules

harbor-repo.vmware.com/dockerhub-proxy-cache/cfpersi/nfs-unit-tests:
 - has go version from nfs release and ginkgo

harbor-repo.vmware.com/dockerhub-proxy-cache/cfpersi/nfs-cats:
 - installs ganesha and exposes ports
 - this image is "cf-push"ed in cats

harbor-repo.vmware.com/dockerhub-proxy-cache/cfpersi/smb-unit-tests:
 - installs golang release from smb release, ginkgo

harbor-repo.vmware.com/dockerhub-proxy-cache/cfpersi/smb-k8s-pats:
 - aws, google cloud, bosh for spinning up k8s clusters/cf4k8s

harbor-repo.vmware.com/dockerhub-proxy-cache/cfpersi/smb-k8s-kind-tests:
 - installs golang version for smb-volume-k8s-release, docker-in-docker

harbor-repo.vmware.com/dockerhub-proxy-cache/cfpersi/cnb-cifs-run-stack:
 - installs cifs-utils on top of the regular cnb-run-stack

