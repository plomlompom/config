#!/bin/sh
# Set up plomlompom.com web server.
set -e

config_tree_prefix="${HOME}/config/all_new_2018"
setup_scripts_dir="${config_tree_prefix}/setup_scripts"
cd "${setup_scripts_dir}"

./hardlink_etc.sh web
./setup_sendonly.sh
sed -i "s/REPLACE_fqdn_ECALPER/$(hostname -f)/g" /etc/nginx/nginx.conf
sed -i "s/REPLACE_fqdn_ECALPER/$(hostname -f)/g" /etc/gitweb.conf
cd /var/
rm -rf www
git clone plom@core.plomlompom.com:repos/website www
apt -y -o Dpkg::Options::=--force-confold install nginx gitweb fcgiwrap
mkdir /var/public_repos
chown plom:plom /var/public_repos
iptables-restore /etc/iptables/rules.v4
