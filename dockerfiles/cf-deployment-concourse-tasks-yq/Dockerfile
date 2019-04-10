FROM relintdockerhubpushbot/cf-deployment-concourse-tasks

RUN apt-get install -y python3-pip
RUN pip3 install yq

# we need ipcalc to convert bbl output cidr ranges into a
# format that the openvpnserver expects (netmask format)
RUN apt-get install -y ipcalc
