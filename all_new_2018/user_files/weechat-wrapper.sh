#!/bin/sh

# Enforce ~/.weechatrc as sole persistent weechat config file.
#~/config/bin/simplemail.sh ~/config/mails/weechat_restart_reminder
rm -rf ~/.weechat/
WEECHATCONF=`tr '\n' ';' < ~/.weechatrc`
weechat -r "$WEECHATCONF"
rm -rf ~/.weechat/
