#!/bin/sh
set -e

./hardlink_etc.sh web
sed -i "s/REPLACE_fqdn_ECALPER/$(hostname -f)/g" /etc/nginx/nginx.conf
sed -i "s/REPLACE_fqdn_ECALPER/$(hostname -f)/g" /etc/gitweb.conf
apt -y -o Dpkg::Options::=--force-confold install nginx gitweb fcgiwrap
cd /var/
rm -rf www
git clone plom@core.plomlompom.com:repos/website www
su plom -c 'cd /var/ && mkdir public_repos'
iptables-restore /etc/iptables/rules.v4
