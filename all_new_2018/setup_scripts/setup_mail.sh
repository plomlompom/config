#/bin/sh
set -e

# Check we have the necessary arguments.
if [ $# -lt 2 ]; then
    echo "Give arguments of mail domain and DKIM selector."
    echo "Also, if hosting mail for entire domain, give third argument 'domainwide'."
    false
fi
mail_domain="$1"
dkim_selector="$2"
domainwide="$3"

config_tree_prefix="${HOME}/config/all_new_2018"
setup_scripts_dir="${config_tree_prefix}/setup_scripts"
cd "${setup_scripts_dir}"

# Set up DKIM key. Only keep opendkim-tools on system if pre-installed.
mkdir -p /etc/dkimkeys/
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

# Link and adapt mail-server-specific /etc/ files.
./hardlink_etc.sh mail
sed -i "s/REPLACE_maildomain_ECALPER/${mail_domain}/g" /etc/mailutils.conf
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
cp "${config_tree_prefix}/user_files/dovecot.sieve" /home/plom/.dovecot.sieve
chown plom:plom /home/plom/.dovecot.sieve

# Pingmail setup.
apt install -y mailutils
cp "${config_tree_prefix}/user_files/pingmailrc" /home/plom/.pingmailrc
chown plom:plom /home/plom/.pingmailrc
su plom -c "cd && git clone https://plomlompom.com/repos/clone/pingmail.git"

# In addition to our postfix server receiving mails, we funnel mails from a
# POP3 account into dovecot via fetchmail. It might make sense to adapt the
# ~/.dovecot.sieve to move mails targeted to the fetched mail account to their
# own mbox.
apt -y install fetchmail
cp "${config_tree_prefix}/user_files/fetchmailrc" /home/plom/.fetchmailrc
chown plom:plom /home/plom/.fetchmailrc
chmod 0700 /home/plom/.fetchmailrc

# Pingmail and fetchmail have some systemd timers waiting. To let systemd
# know about them, do this.
systemctl daemon-reload

# Final advice to user.
echo "TODO: Ensure MX entry for your system in your DNS configuration."
echo "TODO: Ensure a proper SPF entry for this system in your DNS configuration; something like 'v=spf1 mx -all' mapped to your host."
echo "TODO: passwd plom for IMAPS login"
echo "TODO: adapt /home/plom/.fetchmailrc and then do: systemctl start fetchmail.timer"
echo "TODO: adapt /home/plom/.dovecot.sieve and /home/plom/.pingmailrc (sieve mail by pingmail target person into mbox defined in .pingmailrc), then run: systemctl start pingmail.timer"
echo "TODO: Add the following DKIM entry to your DNS configuration (possibly with slightly changed host entry – if your mail domain includes a subdomain, append that with a dot):"
cat "${dkim_selector}.txt"
