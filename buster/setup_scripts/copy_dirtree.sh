#!/bin/sh
# Copy files in argument-selected subdirectories of $1 to subdirectories
# of $2 (which may be an empty string), e.g. with $1 of "etc_files", $2
# of "" and $3 of "all", copy files below etc_files/all such as
# etc_files/all/etc/foo/bar to equivalent locations below / such as
# /etc/foo/bar. Create directories as necessary. Multiple arguments after
# $3 are possible.
#
# CAUTION: This removes original files at the affected paths.
set -e

if [ "$#" -lt 3 ]; then
    echo 'Need arguments: source root, target root, modules.'
    false
fi
source_root="$1"
target_root="$2"
shift 2

config_tree_prefix="${HOME}/config/buster"
etc_files_dir="${config_tree_prefix}/etc_files"

for target_module in "$@"; do
    cd "${source_root}/${target_module}"
    for path in $(find . -type f); do
        target_path="${target_root}"$(echo "${path}" | cut -c2-)
        source_path=$(realpath "${path}")
        dir=$(dirname "${target_path}")
        mkdir -p "${dir}"
        cp "${source_path}" "${target_path}"
    done
done
