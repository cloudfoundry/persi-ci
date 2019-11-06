FROM relintdockerhubpushbot/cf-deployment-concourse-tasks as golang_version

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y awscli
RUN apt-get install -y python3-pip
RUN pip3 install yq