#!/bin/sh
set -e

# Ensure we have a GPG target to encrypt to.
if [ $# -lt 1 ]; then
    echo "Need public key ID as argument."
    false
fi
gpg_key="$1"

config_tree_prefix="${HOME}/config/all_new_2018"
apt -y install gnupg dirmngr
keyservers='sks-keyservers.net/ keys.gnupg.net'
set +e
while true; do
    do_break=0
    for keyserver in $(echo "${keyservers}"); do
        su plom -c "gpg --no-tty --keyserver $keyserver --recv-key ${gpg_key}"
        if [ $? -eq "0" ]; then
            do_break=1
            break
        fi
        echo "Attempt with keyserver ${keyserver} unsuccessful, trying other."
    done
    if [ "${do_break}" -eq "1" ]; then
        break
    fi
done
set -e
# TODO: We may remove dirmngr here if only this script installed it.
