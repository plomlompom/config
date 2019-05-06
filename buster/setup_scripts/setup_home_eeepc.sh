#!/bin/sh
set -e

config_tree_prefix="${HOME}/config/buster"
setup_scripts_dir="${config_tree_prefix}/setup_scripts"
public_repos_dir=~/public_repos

cd
mkdir -p "${public_repos_dir}"
if [ ! -d "${HOME}/${public_repos_dir}/config" ]; then
    cd "${public_repos_dir}"
    git clone https://plomlompom.com/repos/clone/config
fi
cd "${setup_scripts_dir}"
./copy_dirtree.sh "${config_tree_prefix}/home_files" "/root" minimal user_eeepc
curl -fsSl https://raw.githubusercontent.com/tridactyl/tridactyl/78e662efefd1f4af2bdb2a53edecf03b535b997b/native/install.sh | bash
echo "As tridactyl user, don't forget to do :source on the first Firefox run and then re-start."
