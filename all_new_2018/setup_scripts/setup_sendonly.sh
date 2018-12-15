#!/bin/sh
# This sets up the minimum of a mail server necessary to send out mails
# to the world.
set -e

config_tree_prefix="${HOME}/config/all_new_2018"
setup_scripts_dir="${config_tree_prefix}/setup_scripts"
cd "${setup_scripts_dir}"

./hardlink_etc.sh sendonly
echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections
echo "postfix postfix/mailname string $(hostname -f)" | debconf-set-selections
echo "$(hostname -f)" > /etc/mailname
apt install -y postfix
