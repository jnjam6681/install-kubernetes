#!/bin/bash
DOCKER_COMPOSE_VERSION="1.22.0"

###############################################################################
#                                                                             #
#  + install on other node with ssh.                                          #
# ssh user@$IPaddress "bash -s" < ./1-install-docker.sh
#
###############################################################################

# install docker ce
echo 'install docker-ce'
apt-get update
apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"
apt-get update
apt-get install -y docker-ce
# apt-get install -y docker-ce=18.06.1~ce~3-0~ubuntu
echo 'install docker-ce finish !!'

# install docker compose
echo 'install docker-compose'
curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
echo 'install docker-compose finish !!'
