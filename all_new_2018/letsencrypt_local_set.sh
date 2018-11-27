#!/bin/sh
set -e

# Ensure we have a mail address as argument.
if [ $# -lt 1 ]; then
    echo "Need mail address as argument."
    false
fi
mail_address="$1"

# If port 80 blocked by iptables, open it.
set +e
iptables -C INPUT -p tcp --dport 80 -j ACCEPT
open_iptables="$?"
set -e
if [ "${open_iptables}" -eq "1" ]; then
    iptables -A INPUT -p tcp --dport 80 -j ACCEPT
fi

# Create new certificate and copy it to /etc/letsencrypt.
certbot certonly --standalone --agree-tos -m "${mail}" -d "$(hostname -f)"

# Remove iptables rule to open port 80 if we added it.
if [ "${open_iptables}" -eq "1" ]; then
    iptables -D INPUT -p tcp --dport 80 -j ACCEPT
fi
