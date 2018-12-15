#!/bin/sh
# Do some of the steps necessary to SSH (key-based) with another server.
set -e

target="$1"

# We need a public key to copy over, so generate it if not found.
if [ ! -f ~/.ssh/id_rsa.pub ]; then
    ssh-keygen
fi

# Add target to ~/.ssh/known_hosts so we don't get
# asked for permission at inopportune moments.
ssh-keyscan -H "$target" >> ~/.ssh/known_hosts

# Tell user what to do.
echo "APPEND FOLLOWING TO TARGET'S ~/.ssh/authorized_keys:"
cat ~/.ssh/id_rsa.pub
