#/bin/sh
set -e

if [ $# -lt 2 ]; then
    echo "Give arguments of mail domain and DKIM selector."
    echo "Also, if hosting mail for entire domain, give third argument 'domainwide'."
    false
fi
mail_domain="$1"
dkim_selector="$2"
domainwide="$3"

# Set up DKIM key if necessary.
mkdir -p /etc/dkimkeys/
add_dkim_record=0
if [ ! -f "/etc/dkimkeys/${dkim_selector}.private" ]; then
    add_dkim_record=1
    set +e
    dpkg -s opendkim-tools &> /dev/null
    preinstalled="$?"
    set -e
    if [ ! "${preinstalled}" -eq "0" ]; then
        apt install -y opendkim-tools
    fi
    opendkim-genkey -s "${dkim_selector}"
    mv "${dkim_selector}.private" /etc/dkimkeys/
    if [ ! "${preinstalled}" -eq "0" ]; then
        apt -y --purge autoremove opendkim-tools
    fi
fi

# Link and adapt mail-server-specific /etc/ files.
./hardlink_etc.sh mail
sed -i "s/REPLACE_Domain_ECALPER/${mail_domain}/g" /etc/opendkim.conf
sed -i "s/REPLACE_Selector_ECALPER/${dkim_selector}/g" /etc/opendkim.conf
sed -i "s/REPLACE_myhostname_ECALPER/$(hostname -f)/g" /etc/postfix/main.cf
if [ "${domainwide}" = "domainwide" ]; then
    sed -i 's/REPLACE_mydomain_if_domainwide_ECALPER/$mydomain/g' /etc/postfix/main.cf
else
    sed -i 's/REPLACE_mydomain_if_domainwide_ECALPER//g' /etc/postfix/main.cf
fi
# Since we re-set the iptables rules, we need to reload them.
iptables-restore /etc/iptables/rules.v4

# Some useful debconf selections.
echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections
echo "ssl_cert = </etc/letsencrypt/live/$(hostname -f)/fullchain.pem" > /etc/dovecot/conf.d/99-ssl-certs.conf
echo "ssl_key = </etc/letsencrypt/live/$(hostname -f)/privkey.pem" >> /etc/dovecot/conf.d/99-ssl-certs.conf

# The second line should not be necessary due to the first line, but for
# some reason the installation forgets to set up /etc/mailname early
# enough to not (when running newaliases) stumble over its absence.
echo "postfix postfix/mailname string ${mail_domain}" | debconf-set-selections
echo "${mail_domain}" > /etc/mailname

# Everything should now be ready for installations. Note that we don't
# strictly need dovecot-lmtpd, as postfix will deliver mail to /var/mail/USER
# in any case, to be found by dovecot; we use it as a transport mechanism to
# allow for sophisticated stuff like dovecot-side sieve filtering (installed
# with dovecot-sieve).
apt install -y -o Dpkg::Options::=--force-confold postfix dovecot-imapd dovecot-lmtpd dovecot-sieve opendkim
echo "TODO: Ensure MX entry for your system in your DNS configuration."
echo "TODO: Ensure a proper SPF entry for this system in your DNS configuration; something like 'v=spf1 mx -all' mapped to your host."
if [ "${add_dkim_record}" -eq "1" ]; then
    echo "TODO: Add the following DKIM entry to your DNS configuration (possibly with slightly changed host entry – if your mail domain includes a subdomain, append that with a dot):"
    cat "${dkim_selector}.txt"
fi
echo "TODO: passwd plom"
