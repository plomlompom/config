#!/bin/sh
# Copy over LetsEncrypt certificates from another server.
set -e

# Ensure we have a server name as argument.
if [ $# -lt 1 ]; then
    echo "Need server as argument."
    false
fi
server="$1"

# Copy over.
ssh -t plom@${server} 'su -c "cd /etc/ && tar cf letsencrypt.tar letsencrypt && chown plom:plom letsencrypt.tar && mv letsencrypt.tar /home/plom/"'
scp plom@${server}:~/letsencrypt.tar .
apt -y install certbot
rmdir /etc/letsencrypt
mv letsencrypt.tar /etc/
cd /etc/
tar xf letsencrypt.tar
rm letsencrypt.tar
