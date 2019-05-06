#!/bin/sh
set -e

secrets_dev="sdb"
source_dir="/media/${secrets_dev}/to_usb"
target_dir="${HOME}/tmp_to_usb"
borgkeys_dir=~/.config/borg/keys
ssh_dir=~/.ssh
while [ ! -e /dev/"${secrets_dev}" ]; do
    echo "Put secrets drive into slot for /dev/${secrets_dev}, then hit Return."
    read ignore
done
sudo pmount /dev/"${secrets_dev}"
cp -a "${source_dir}" "${target_dir}"
sudo pumount "${secrets_dev}"
echo "You can remove /dev/${secrets_dev} now."
cd "${target_dir}"
mkdir -p "${ssh_dir}"
echo "Setting up .ssh"
cp id_rsa ~/.ssh
ssh-keygen -y -f ~/.ssh/id_rsa > ~/.ssh/id_rsa.pub
tar xf borg_keyfiles.tar
mkdir -p "${borgkeys_dir}"
mv borg_keyfiles/* "${borgkeys_dir}"
cd
rm -rf "${target_dir}"
