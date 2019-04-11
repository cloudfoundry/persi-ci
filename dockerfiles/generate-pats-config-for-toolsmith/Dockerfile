FROM ubuntu:xenial


RUN apt-get update -y
RUN apt-get install jq curl -y


RUN curl https://raw.githubusercontent.com/starkandwayne/homebrew-cf/master/public.key | apt-key add -
RUN echo "deb http://apt.starkandwayne.com stable main" | tee /etc/apt/sources.list.d/starkandwayne.list
RUN apt-get update -y
RUN apt-get install -y om
