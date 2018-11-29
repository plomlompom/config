#!/bin/sh
# Install or copy LetsEncrypt certificates on/from server.
#
# First argument: server
# Second argument: "get" or "put"
#
# "get" copies the server's /etc/letsencrypt to a local letsencrypt.tar.
#
# "set" copies a local letsencrypt.tar to the server's /etc/letsencrypt.
set -e

# Ensure we have a server name as argument.
if [ $# -lt 2 ]; then
    echo "Need server and action as arguments."
    false
fi
server="$1"
action="$2"

# So we only get asked once for decrypting our key.
eval $(ssh-agent)
ssh-add ~/.ssh/id_rsa

if [ "${action}" = "get" ]; then
    # Get /etc/letsencrypt/ as tar file.
    ssh -t plom@${server} 'su -c "cd /etc/ && tar cf letsencrypt.tar letsencrypt && chown plom:plom letsencrypt.tar && mv letsencrypt.tar /home/plom/"'
    scp plom@${server}:~/letsencrypt.tar .
elif [ "${action}" = "put" ]; then
    # Expand letsencrypt.tar to /etc/letsencrypt/ on server.
    scp letsencrypt.tar plom@${server}:~/
    ssh -t plom@${server} 'su -c "rmdir /etc/letsencrypt && mv letsencrypt.tar /etc/ && cd /etc/ && tar xf letsencrypt.tar && rm letsencrypt.tar"'
else
    echo "Action must be 'get', or 'put'."
    false
fi
