#/bin/sh
set -e

echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections
echo "postfix postfix/mailname string $(hostname -f)" | debconf-set-selections
apt install postfix
mkdir -p /etc/dovecot/conf.d/
echo "ssl_cert = </etc/letsencrypt/live/$(hostname -f)/fullchain.pem" > /etc/dovecot/conf.d/99-ssl-certs.conf
echo "ssl_key = </etc/letsencrypt/live/$(hostname -f)/privkey.pem" >> /etc/dovecot/conf.d/99-ssl-certs.conf
apt install dovecot-imapd
