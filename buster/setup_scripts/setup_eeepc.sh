#!/bin/sh
set -e

if [ "$#" -ne 1 ]; then
    echo 'Need exactly one argument (hostname).'
    false
fi
hostname="$1"

config_tree_prefix="${HOME}/config/buster"
setup_scripts_dir="${config_tree_prefix}/setup_scripts"
cd "${setup_scripts_dir}"
./setup.sh "${hostname}" ""
./copy_dirtree.sh "${config_tree_prefix}/etc_files" "" eeepc
./install_for_target.sh eeepc

if [ ! -d "/home/plom" ]; then
    adduser --disabled-password --gecos "" plom
    su -c "cd && git clone https://plomlompom.com/repos/clone/config" plom
    su -c "~/config/buster/setup_scripts/copy_dirtree.sh ~/config/buster/home_files ~ eeepc" plom
fi
