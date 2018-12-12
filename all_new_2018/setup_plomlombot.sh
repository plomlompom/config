#!/bin/sh
set -e

config_tree_prefix="${HOME}/config/all_new_2018/"
irclogs_dir=/var/www/html/irclogs
cp "${config_tree_prefix}"/user_scripts/plomlombot_daemon.sh /home/plom/
chown plom:plom /home/plom/plomlombot_daemon.sh
apt -y install screen python3-venv
su plom -c "cd && git clone /var/public_repos/plomlombot-irc"
systemctl enable /etc/systemd/system/plomlombot.service
service plomlombot start
mkdir -p "${irclogs_dir}"
chown -r plom:plom "${irclogs_dir}"
echo "Don't forget to add an encryption key to plom's key chain and to his ~/.plomlombot."
