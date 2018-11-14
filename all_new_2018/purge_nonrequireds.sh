#!/bin/sh
# This script removes all Debian packages that are not of Priority
# "required" or not depended on by packages of priority "required"
# or not listed in the argument-selected files of apt-mark/.
set -e

config_tree_prefix="${HOME}/config/all_new_2018/apt-mark/"

dpkg-query -Wf '${Package} ${Priority}\n' | grep ' required' | sed 's/ required//' > /tmp/list_white_unsorted
for target in "$@"; do
    path="${config_tree_prefix}${target}"
    cat "${path}" | while read line; do
        if [ ! $(echo "${line}" | cut -c1) = "#" ]; then
            echo "${line}" >> /tmp/list_white_unsorted
        fi
    done
done
sort /tmp/list_white_unsorted > /tmp/list_white
dpkg-query -Wf '${Package}\n' > /tmp/list_all_packages
sort /tmp/list_all_packages > /tmp/foo
mv /tmp/foo /tmp/list_all_packages
comm -3 /tmp/list_all_packages /tmp/list_white > /tmp/list_black
apt-mark auto `cat /tmp/list_black`
DEBIAN_FRONTEND=noninteractive apt-get -y --purge autoremove
rm /tmp/list_all_packages /tmp/list_white_unsorted /tmp/list_white /tmp/list_black
