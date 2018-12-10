#!/bin/sh
set -e

config_tree_prefix="${HOME}/config/all_new_2018//"
cp "${config_tree_prefix}"/user_scripts/start_plomlombot.sh /home/plom/
chown plom:plom /home/plom/start_plomlombot.sh
apt -y install screen python3-venv
systemctl enable /etc/systemd/system/plomlombot.service
service start plomlombot
mkdir -p /var/www/html/irclogs
ln /home/plom/plomlombot_db/6f322d574618816aa2d6d1ceb4fd2551/789a38c5af11bb71833d89cd74387fcb/logs /var/www/html/irclogs/plomlompomtest
