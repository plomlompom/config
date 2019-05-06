#!/bin/sh
set -e

public_repos_dir="${HOME}/public_repos"
config_tree_prefix="${public_repos_dir}/config/buster"
setup_scripts_dir="${config_tree_prefix}/setup_scripts"
repos_list_file="${public_repos_dir}/repos"
secrets_dev="sdb"
source_dir="/media/${secrets_dev}/to_usb"
target_dir="${HOME}/tmp_to_usb"
borgkeys_dir=~/.config/borg/keys
ssh_dir=~/.ssh

ensure_repo() {
    repo_name="${1}"
    if [ ! -d "${public_repos_dir}/${repo_name}" ]; then
        cd "${public_repos_dir}"
        git clone https://plomlompom.com/repos/clone/${repo_name}
    fi
}

cd
mkdir -p "${public_repos_dir}"
ensure_repo config
cd "${setup_scripts_dir}"
./copy_dirtree.sh "${config_tree_prefix}/home_files" "${HOME}" minimal user_eeepc
cat "${repos_list_file}" | while read line; do
    ensure_repo "${line}"
done
curl -fsSl https://raw.githubusercontent.com/tridactyl/tridactyl/78e662efefd1f4af2bdb2a53edecf03b535b997b/native/install.sh | bash
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
echo "TODO: As tridactyl user, don't forget to do :source on the first Firefox run and then re-start."
