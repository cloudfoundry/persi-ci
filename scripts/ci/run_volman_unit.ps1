$ErrorActionPreference = “Stop”;
trap { $host.SetShouldExit(1) }


cd diego-release


$env:GOPATH=$PWD
$env:PATH="$PWD/bin;$env:PATH"

go install github.com/onsi/ginkgo/ginkgo

cd src/code.cloudfoundry.org/volman
ginkgo -r -keepGoing -p -trace -randomizeAllSpecs -progress --race

cd ../voldriver
ginkgo -r -keepGoing -p -trace -randomizeAllSpecs -progress --race
