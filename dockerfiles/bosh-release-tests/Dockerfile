FROM golang:latest

RUN set -eux \
  ; curl -s https://api.github.com/repos/cloudfoundry/bosh-cli/releases/latest \
    | grep "browser_download_url.*linux-amd64" \
    | cut -d : -f 2,3 \
    | tr -d \" \
    | wget -O /usr/local/bin/bosh -qi  - \
  ; chmod +x /usr/local/bin/bosh \
  ; bosh -v

RUN set -eux \
  ; go install github.com/onsi/ginkgo/ginkgo@latest \
  ; ginkgo version

ENV PATH=$PATH:$GOPATH/bin
