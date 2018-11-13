#!/bin/sh
# This script turns a fresh server with password-based root access to
# one of only key-based access and only to new non-root account plom.
#
# CAUTION: This is optimized for a *fresh* setup. It will overwrite any
# pre-existing ~/.ssh/authorized_keys of user plom with one that solely
# contains the local ~/.ssh/id_rsa.pub, and also any old
# /etc/ssh/sshd_config.
#
# Dependencies: ssh, scp, sshpass, ~/.ssh/id_rsa.pub
set -e

# Ensure we have a server name as argument.
if [ $# -eq 0 ]; then
    echo "Need server as argument."
    false
fi
server="$1"

# Ask for root password only once, sshpass will re-use it then often.
stty -echo
printf "Server root password: "
read PW_ROOT
stty echo
printf "\n"
export SSHPASS="$PW_ROOT"

# Create user plom, and his ~/.ssh/authorized_keys based on the local
# ~/.ssh/id_rsa.pub; ensure the result has proper permissions and
# ownerships. Then disable root and pw login, and restart ssh daemon.
#
# This could be a line or two shorter by using ssh-copy-id, but that
# would require setting a password for user plom otherwise not needed.
sshpass -e scp ~/.ssh/id_rsa.pub root@"$server":/tmp/authorized_keys
sshpass -e ssh root@"$server" \
        'useradd -m plom && '\
        'mkdir /home/plom/.ssh && '\
        'chown plom:plom /tmp/authorized_keys && '\
        'chmod u=rw,go= /tmp/authorized_keys && '\
        'mv /tmp/authorized_keys /home/plom/.ssh/'
sshpass -e scp sshd_config root@"$server":/etc/ssh/sshd_config
sshpass -e ssh root@"$server" 'service ssh restart'
