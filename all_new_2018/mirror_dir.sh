#!/bin/sh
set -e

if [ $# -lt 2 ]; then
    echo "Need server and directory as arguments."
    false
fi
server=$1
dir=$2
path_package=/tmp/delete.tar

eval `ssh-agent`
ssh-add
cd
ssh plom@"${server}" "cd \"${dir}\" && tar cf ${path_package} ."
scp plom@"${server}":"${path_package}" "${path_package}"
mkdir -p "${dir}"
cd "${dir}"
tar xf "${path_package}"
cd
rm "${path_package}"
ssh plom@"${server}" rm "${path_package}"
