#!/bin/sh
# Symbolically link files to those in argument-selected subdirectories
# of linkable_etc_files//, e.g. link /etc/foo/bar to
# linkable_etc_files/$1/etc/foo/bar and so on. Create directories as
# necessary.
# CAUTION: This removes original files at the affected paths.
set -e

for target in "$@"; do
    cd "${config_tree_prefix}${target}"
    for path in $(find . -type f); do
        linking=$(echo "${path}" | cut -c2-)
        linked=$(realpath "${path}")
        dir=$(dirname "${linking}")
        mkdir -p "${dir}"
        ln -fs "${linked}" "${linking}"
    done
done
