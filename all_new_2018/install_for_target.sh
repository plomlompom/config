#!/bin/sh
# Walks through the package names in the argument-selected files of
# apt-mark/ and ensures the respective packages are installed.
#
# Ignores anything in an apt-mark/ file after the last newline.
set -e

config_tree_prefix="${HOME}/config/all_new_2018/apt-mark/"

for target in "$@"; do
    path="${config_tree_prefix}${target}"
    cat "${path}" | while read line; do
        echo "$line"
        if [ ! $(echo "${line}" | cut -c1) = "#" ]; then
            apt-get -y install "${line}"
        fi
    done
done
