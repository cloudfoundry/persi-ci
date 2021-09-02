FROM relintdockerhubpushbot/cf-deployment-concourse-tasks

RUN echo "installing smith"
COPY smith_linux_amd64.tar.gz /tmp/smith_linux_amd64.tar.gz
RUN tar -xvf /tmp/smith_linux_amd64.tar.gz
RUN mv smith /usr/local/bin

RUN echo "installing om"
RUN wget -q -O - https://raw.githubusercontent.com/starkandwayne/homebrew-cf/master/public.key |  apt-key add -
RUN echo "deb http://apt.starkandwayne.com stable main" |  tee /etc/apt/sources.list.d/starkandwayne.list
RUN apt-get --allow-releaseinfo-change-suite update && apt-get install om -y && apt-get install jq -y