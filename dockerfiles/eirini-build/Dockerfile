from ubuntu

RUN apt-get update && apt-get install -y curl gnupg wget git make software-properties-common
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
RUN add-apt-repository ppa:longsleep/golang-backports
RUN apt-get update && apt-get install -y google-cloud-sdk golang-go


RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin/kubectl
RUN kubectl version --client=true

RUN wget https://get.helm.sh/helm-v2.14.3-linux-amd64.tar.gz
RUN tar -xvf helm-v2.14.3-linux-amd64.tar.gz -C /tmp/
RUN mv /tmp/linux-amd64/helm /usr/local/bin/helm
RUN mv /tmp/linux-amd64/tiller /usr/local/bin/tiller


RUN helm init --client-only
RUN helm plugin install https://github.com/databus23/helm-diff --version master


RUN curl -L -o /usr/local/bin/helmfile https://github.com/roboll/helmfile/releases/download/v0.89.0/helmfile_linux_386
RUN chmod +x /usr/local/bin/helmfile

RUN wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | apt-key add -
RUN echo "deb https://packages.cloudfoundry.org/debian stable main" | tee /etc/apt/sources.list.d/cloudfoundry-cli.list
RUN apt-get update
RUN apt-get install cf-cli


ENV PATH=$PATH:/root/go/bin
