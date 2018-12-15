#!/bin/sh
# Hard link files to those in argument-selected subdirectories of
# linkable_etc_files//, e.g. link /etc/foo/bar to
# linkable_etc_files/$1/etc/foo/bar and so on. Create directories as
# necessary. We do the hard linking so files that should be readable to
# non-root in /etc/ remain so despite having a path below /root/, as
# symbolic links point into /root/ without making the targets readable
# to non-root.
# CAUTION: This removes original files at the affected paths.
set -e

config_tree_prefix="${HOME}/config/all_new_2018"
linkable_files_dir="${config_tree_prefix}/linkable_etc_files"

for target in "$@"; do
    cd "${linkable_files_dir}/${target}"
    for path in $(find . -type f); do
        linking=$(echo "${path}" | cut -c2-)
        linked=$(realpath "${path}")
        dir=$(dirname "${linking}")
        mkdir -p "${dir}"
        ln -f "${linked}" "${linking}"
    done
done
