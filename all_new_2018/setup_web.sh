#!/bin/sh
set -e

./hardlink_etc.sh web
sed -i "s/REPLACE_fqdn_ECALPER/$(hostname -f)/g" /etc/nginx/nginx.conf
apt -y -o Dpkg::Options::=--force-confold install nginx
iptables-restore /etc/iptables/rules.v4
