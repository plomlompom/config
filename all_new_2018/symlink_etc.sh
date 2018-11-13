#!/bin/sh
# Symbolically link files to those under linkable_etc_files/$1/, e.g.
# link /etc/foo/bar to linkable_etc_files/$1/etc/foo/bar. Create
# directories as necessary.
# CAUTION: This removes original files at the affected paths.
set -e

target="$1"
config_tree_prefix="${HOME}/config/all_new_2018/linkable_etc_files/"
cd "${config_tree_prefix}""${target}"
for path in $(find .); do
    dest=$(echo "${path}" | cut -c2-)
    ln -fs "${path}" "${dest}"
done
