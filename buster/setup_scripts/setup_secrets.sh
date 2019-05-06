#!/bin/sh
set -e

dev="sdb"
source_dir="/media/${dev}/to_usb"
target_dir="${HOME}/tmp_to_usb"
borgkeys_dir=~/.config/borg/keys
ssh_dir=~/.ssh
while [ ! -e /dev/"${dev}" ]; do
    echo "Put secrets drive into slot for /dev/${dev}, then hit Return."
    read
done
sudo pmount /dev/"${dev}"
cp -a "${source_dir}" "${target_dir}"
sudo pumount "${dev}"
echo "You can remove /dev/${dev} now."
cd "${target_dir}"
mkdir -p "${ssh_dir}"
cp id_rsa ~/.ssh
ssh-keygen -y -f ~/.ssh/id_rsa > ~/.ssh/id_rsa.pub
tar xf borg_keyfiles.tar
mkdir -p "${borgkeys_dir}"
mv borg_keyfiles/* "${borgkeys_dir}"
cd
rm -rf "${target_dir}"
