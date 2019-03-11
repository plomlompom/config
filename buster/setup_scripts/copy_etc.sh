#!/bin/sh
# Copy files to those in argument-selected subdirectories of
# linkable_etc_files//, e.g. copy /etc/foo/bar to
# linkable_etc_files/$1/etc/foo/bar and so on. Create directories as
# necessary.
#
# CAUTION: This removes original files at the affected paths.
set -e

config_tree_prefix="${HOME}/config/buster"
etc_files_dir="${config_tree_prefix}/etc_files"

for target in "$@"; do
    cd "${etc_files_dir}/${target}"
    for path in $(find . -type f); do
        target=$(echo "${path}" | cut -c2-)
        source=$(realpath "${path}")
        dir=$(dirname "${target}")
        mkdir -p "${dir}"
        cp "${source}" "${target}"
    done
done
