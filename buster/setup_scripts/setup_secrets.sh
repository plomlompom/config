#!/bin/sh
set -e

if [ "$#" -ne 1 ]; then
    echo 'Need exactly one argument (directory).'
    false
fi
directory="$1"
borgkeys_dir=~/.config/borg/keys
ssh_dir=~/.ssh

cd "${directory}"
mkdir -p "${ssh_dir}"
cp id_rsa ~/.ssh
ssh-keygen -y -f ~/.ssh/id_rsa > ~/.ssh/id_rsa.pub
tar xf borg_keyfiles.tar
mkdir -p "${borgkeys_dir}"
mv borg_keyfiles/* "${borgkeys_dir}"
rmdir borg_keyfiles
