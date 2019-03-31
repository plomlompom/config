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
./instal_for_target.sh eeepc
