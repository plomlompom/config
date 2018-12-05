#!/bin/sh
set -e

./hardlink_etc.sh web
sed -i "s/REPLACE_fqdn_ECALPER/$(hostname -f)/g" /etc/nginx/nginx.conf
sed -i "s/REPLACE_fqdn_ECALPER/$(hostname -f)/g" /etc/gitweb.conf
apt -y -o Dpkg::Options::=--force-confold install nginx gitweb fcgiwrap
iptables-restore /etc/iptables/rules.v4
