#!/bin/sh
set -x
set -e
selector=$1
file=$2

if [ "$(id -u)" -eq "0" ]; then
    echo "Must be run as root."
    exit
fi

apt-get -y install opendkim opendkim-tools
cp ~/config/systemfiles/opendkim.conf /etc/opendkim.conf

if [ -f /etc/opendkim/dkim.key ]; then
    cp /etc/opendkim/dkim.key /etc/opendkim/dkim.key~
fi

sed -r -i 's/^#Selector .*$/Selector '$selector'/' /etc/opendkim.conf

if [ ! -f $file ]; then
    opendkim-genkey -d plomlompom.com -s $selector
    mv "$selector".private /etc/opendkim/dkim.key
else
    cp $file /etc/opendkim/dkim.key
fi

cp ~/config/systemfiles/main.cf /etc/postfix/main.cf
echo >> /etc/postfix/main.cf << EOF

# Use opendkim at given port as mail filter.
non_smtpd_milters = inet:localhost:12301
smtpd_milters = inet:localhost:12301
EOF
service postfix restart
service opendkim restart

echo 'TAKE NOTE:'
if [ -f $selector.txt ]; then
    echo 'Apply the content of '$selector'.txt to your DNS record!'
    cat $selector.txt 
else
    echo 'Make sure the DKIM TXT entry in your DNS record matches!'
fi
