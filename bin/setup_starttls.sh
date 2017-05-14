#!/bin/sh
set -x
set -e
key=$1
cert=$2

if [ ! "$(id -u)" -eq "0" ]; then
  echo "Must be run as root."
  exit 1
fi

key_target=/etc/postfix/key.pem
if [ ! -n "$key" ]; then
  if [ ! -f "${key_target}" ]; then
    (umask 077; openssl genrsa -out "${key_target}" 2048)
  fi
else
  cp "$key" "${key_target}"
fi

fqdn=$(postconf -h myhostname)
cert_target=/etc/postfix/cert.pem
if [ ! -n "$cert" ]; then
  if [ ! -f "${cert_target}" ]; then
    openssl req -new -key "${key_target}" -x509 -subj "/CN=${fqdn}" -days 3650 -out "${cert_target}"
  fi
else
  cp "$cert" "${cert_target}"
fi

cat >> /etc/postfix/main.cf << EOF

# Enable server-side STARTTLS. 
smtpd_tls_cert_file = /etc/postfix/cert.pem
smtpd_tls_key_file = /etc/postfix/key.pem
smtpd_tls_security_level = may
EOF
service postfix restart
