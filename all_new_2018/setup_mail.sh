#/bin/sh
set -e

selector=$1
if [ ! -n "${selector}" ]; then
    echo "Give DKIM selector argument."
    false
fi

# Set up DKIM key if necessary.
mkdir -p /etc/dkimkeys/
add_dkim_record=0
if [ ! -f "/etc/dkimkeys/${dkim_selector}.private" ]; then
    add_dkim_record=1
    dpkg -s opendkim-tools &> /dev/null
    preinstalled="$?"
    if [ ! "${preinstalled}" -eq "0" ]; then
        apt install -y opendkim-tools
    fi
    opendkim-genkey -s "${dkim_selector}"
    if [ ! "${preinstalled}" -eq "0" ]; then
        apt --purge autoremove opendkim-tools
    fi
fi

# Link and adapt mail-server-specific /etc/ files.
./hardlink_etc.sh mail
sed -i "s/REPLACE_Domain_ECALPER/$(hostname -f)/g" /etc/opendkim.conf
sed -i "s/REPLACE_Selector_ECALPER/${dkim_selector}/g" /etc/opendkim.conf

# Some useful debconf selections.
echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections
echo "ssl_cert = </etc/letsencrypt/live/$(hostname -f)/fullchain.pem" > /etc/dovecot/conf.d/99-ssl-certs.conf
echo "ssl_key = </etc/letsencrypt/live/$(hostname -f)/privkey.pem" >> /etc/dovecot/conf.d/99-ssl-certs.conf

# The second line should not be necessary due to the first line, but for
# some reason the installation forgets to set up /etc/mailname early
# enough to not (when running newaliases) stumble over its absence.
echo "postfix postfix/mailname string $(hostname -f)" | debconf-set-selections
echo "$(hostname -f)" > /etc/mailname

# Everything should now be ready for installations.
apt install -y postfix dovecot-imapd opendkim
echo "TODO: Ensure a proper SPF entry for this system in your DNS configuration."
if [ "${add_dkim_record}" -eq "1" ]; then
    echo "TODO: Add the following DKIM entry to your DNS configuration (possibly with slightly changed host entry – if your mail domain includes a subdomain, append that with a dot):"
    cat "${dkim_selector}.txt"
fi
