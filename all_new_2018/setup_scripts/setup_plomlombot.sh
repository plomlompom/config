#!/bin/sh
set -e

# Ensure we have a GPG target to encrypt to.
if [ $# -lt 1 ]; then
    echo "Need public key ID as argument."
    false
fi
gpg_key="$1"

config_tree_prefix="${HOME}/config/all_new_2018"
irclogs_dir=/var/www/html/irclogs
irclogs_pw_dir=/var/www/irclogs_pw
cp "${config_tree_prefix}"/user_files/plomlombot_daemon.sh /home/plom/
chown plom:plom /home/plom/plomlombot_daemon.sh
apt -y install screen python3-venv gnupg dirmngr
keyservers='sks-keyservers.net/ keys.gnupg.net'
set +e
while true; do
    do_break=0
    for keyserver in $(echo "${keyservers}"); do
        su plom -c "gpg --no-tty --keyserver $keyserver --recv-key ${gpg_key}"
        if [ $? -eq "0" ]; then
            do_break=1
            break
        fi
        echo "Attempt with keyserver ${keyserver} unsuccessful, trying other."
    done
    if [ "${do_break}" -eq "1" ]; then
        break
    fi
done
set -e
# TODO: We may remove dirmngr here if only this script installed it.
su plom -c "cd && git clone /var/public_repos/plomlombot-irc"
systemctl enable /etc/systemd/system/plomlombot.service
service plomlombot start
mkdir -p "${irclogs_dir}"
chown -R plom:plom "${irclogs_dir}"
mkdir -p "${irclogs_pw_dir}"
chown -R plom:plom "${irclogs_pw_dir}"
echo "Don't forget to add a file ~/.plomlombot with content such as:"
echo "gpg_key ${gpg_key}"
echo "bot: SCREEN_SESSION_NAME BOT_NAME #CHANNEL_NAME IRC_SERVER_NAME LOGS_USER LOGS_PW"
echo "# file should end in newline or non-interpreted line such as this"
