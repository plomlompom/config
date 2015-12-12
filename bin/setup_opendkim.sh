#!/bin/sh
set -e
selector=$1
file=$2

if [ ! -n "$selector" ]; then
    cat << EOF
Usage: $0 SELECTOR [KEYFILE] - set up DKIM system and configuration

If existing KEYFILE is given, set up DKIM to use SELECTOR and apply key from
KEYFILE.

If existing KEYFILE is not given, generate KEYFILE and DNS TXT file for
SELECTOR.
EOF
    exit
fi

if [ ! "$(id -u)" -eq "0" ]; then
    echo "Must be run as root."
    exit 1
fi

set -x
apt-get -y install opendkim

if [ ! -n "$file" ]; then
    apt-get -y install opendkim-tools
    opendkim-genkey -d plomlompom.com -s $selector
    apt-get -y --purge autoremove opendkim-tools
    set +x
    echo
    echo 'Generated key file at '$selector'.private.'
    echo 'Also generated '$selector'.txt, APPLY its content below to your DNS' \
         'record.'
    echo 'AFTER the waiting time for DNS propagation RERUN this script with' \
          'the key file as SECOND parameter (still use selector as first one).'
    echo
    cat $selector.txt
else
    if [ ! -f "$file" ]; then
        set +x
        echo
        echo "Keyfile $file does not exist."
        exit 1
    fi
    cp ~/config/systemfiles/opendkim.conf /etc/opendkim.conf
    sed -r -i 's/^#Selector .*$/Selector '$selector'/' /etc/opendkim.conf
    mkdir -p /etc/opendkim
    if [ -f /etc/opendkim/dkim.key ]; then
        cp /etc/opendkim/dkim.key /etc/opendkim/dkim.key~
    fi
    cp $file /etc/opendkim/dkim.key
    cp ~/config/systemfiles/main.cf /etc/postfix/main.cf
    cat >> /etc/postfix/main.cf << EOF

# Use opendkim at given port as mail filter.
non_smtpd_milters = inet:localhost:12301
EOF
    service opendkim restart
    service postfix restart
    set +x
    echo
    echo 'Ensure the DKIM TXT entry in your DNS record matches!'
fi
