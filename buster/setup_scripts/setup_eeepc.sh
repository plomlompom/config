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
