$ErrorActionPreference = “Stop”;
trap { $host.SetShouldExit(1) }

function CheckLastExitCode {
  if ($LastExitCode -ne 0) {
    Write-Host "Unit tests failed"
    exit 1
  } else {
    Write-Host "Unit tests passed"
    exit 0
  }
}

cd diego-release

$env:GOPATH=$PWD
$env:PATH="$PWD/bin;$env:PATH"

go install github.com/onsi/ginkgo/ginkgo

cd src/code.cloudfoundry.org/volman
ginkgo -r -keepGoing -p -trace -randomizeAllSpecs -progress --race
CheckLastExitCode

cd ../voldriver
ginkgo -r -keepGoing -p -trace -randomizeAllSpecs -progress --race
CheckLastExitCode
