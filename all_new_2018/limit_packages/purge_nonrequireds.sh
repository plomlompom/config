#!/bin/sh
# This script removes all Debian packages that are not of Priority
# "required" or not depended on by packages of priority "required"
# or not listed in the file ./required_nonrequireds.
# If ./required_nonrequireds does not exist, will abort, as user
# probably does not know what they are doing then.
set -x
set -e

dpkg-query -Wf '${Package} ${Priority}\n' | grep ' required' | sed 's/ required//' > /tmp/list_white_unsorted
cat 'required_nonrequireds' >> /tmp/list_white_unsorted
sort /tmp/list_white_unsorted > /tmp/list_white
dpkg-query -Wf '${Package}\n' > /tmp/list_all_packages
sort /tmp/list_all_packages > /tmp/foo
mv /tmp/foo /tmp/list_all_packages
comm -3 /tmp/list_all_packages /tmp/list_white > /tmp/list_black
apt-mark auto `cat /tmp/list_black`
DEBIAN_FRONTEND=noninteractive apt-get -y --purge autoremove
rm /tmp/list_all_packages /tmp/list_white_unsorted /tmp/list_white /tmp/list_black
