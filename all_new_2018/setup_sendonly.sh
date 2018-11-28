#!/bin/sh
set -e

./hardlink_etc.sh sendonly
echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections
echo "postfix postfix/mailname string $(hostname -f)" | debconf-set-selections
echo "$(hostname -f)" > /etc/mailname

