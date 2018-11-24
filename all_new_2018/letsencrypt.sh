#!/bin/sh
set -e

# Ensure we have a server name as argument.
if [ ! $# -eq 2 ]; then
    echo "Need server and action as argument."
    false
fi
server="$1"
action="$2"

# So we only get asked once for decrypting our key.
eval $(ssh-agent)
ssh-add ~/.ssh/id_rsa

if [ "${action}" = "set" ]; then
    # Install certificate.
    ssh -t plom@${server} "su -c 'apt -y install certbot && certbot certonly --standalone -d ${server}$'"
elif [ "${action}" = "get" ]; then
    # Get /etc/letsencrypt/ as tar file.
    ssh -t plom@${server} 'su -c "cd /etc/ && tar cf letsencrypt.tar letsencrypt && chown plom:plom letsencrypt.tar && mv letsencrypt.tar /home/plom/"'
    scp plom@${server}:~/letsencrypt.tar .
elif [ "${action}" = "put" ]; then
    # Expand letsencrypt.tar to /etc/letsencrypt/ on server.
    scp letsencrypt.tar plom@${server}:~/
    ssh -t plom@${server} 'su -c "rmdir /etc/letsencrypt && mv letsencrypt.tar /etc/ && cd /etc/ && tar xf letsencrypt.tar && rm letsencrypt.tar"'
else
    echo "Action must be 'set', 'get', or 'put'."
    false
fi

