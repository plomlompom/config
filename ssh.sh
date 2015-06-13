#!/bin/sh
set -e
set -x
#apt-get -y install openssh-client
eval `ssh-agent`
ssh-add ~/.ssh/id_rsa
