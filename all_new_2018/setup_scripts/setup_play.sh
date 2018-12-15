#!/bin/sh
set -e

# Ensure we have a GPG target to encrypt to.
if [ $# -lt 1 ]; then
    echo "Need public key ID as argument."
    false
fi
gpg_key="$1"

config_tree_prefix="${HOME}/config/all_new_2018"
setup_scripts_dir="${config_tree_prefix}/setup_scripts"
cd "${setup_scripts_dir}"

config_tree_prefix="${HOME}/config/all_new_2018/"
./hardlink_etc.sh play
apt -y install weechat screen vim
cp "${config_tree_prefix}user_files/encrypter.sh" /home/plom/
chown plom:plom /home/plom/encrypter.sh
cp "${config_tree_prefix}user_files/weechat-wrapper.sh" /home/plom/
chown plom:plom /home/plom/weechat-wrapper.sh
cp "${config_tree_prefix}user_files/weechatrc" /home/plom/.weechatrc
chown plom:plom /home/plom/.weechatrc
apt -y install screen gnupg dirmngr
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
echo "$gpg_key" > /home/plom/.encrypt_target
chown plom:plom /home/plom/.encrypt_target
# TODO: We may remove dirmngr here if only this script installed it.
systemctl daemon-reload
systemctl start encrypt_chatlogs.timer
