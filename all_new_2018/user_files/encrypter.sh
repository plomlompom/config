#!/bin/sh
# Encrypt dated weechatlog files older than one day to GPG target defined in
# ~/.encrypt_target
set -e

gpg_key=$(cat ~/.encrypt_target)
cd ~/weechatlogs/irc/
find . -regextype posix-egrep -regex '^.*/.*/.*\.[0-9]{4}-[0-9]{2}-[0-9]{2}\.weechatlog$' -type f -mtime +1 -exec gpg --recipient "${gpg_key}" --trust-model always --encrypt {} \; -exec rm {} \;

