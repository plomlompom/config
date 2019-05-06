#!/bin/sh
set -e

cd
public_repos_dir=~/public_repos
mkdir -p "${public_repos_dir}"
if [ ! -d "/home/plom/${public_repos_dir}/config" ]; then
    cd "${public_repos_dir}"
    git clone https://plomlompom.com/repos/clone/config
fi
curl -fsSl https://raw.githubusercontent.com/tridactyl/tridactyl/78e662efefd1f4af2bdb2a53edecf03b535b997b/native/install.sh | bash
echo "As tridactyl user, don't forget to do :source on the first Firefox run and then re-start."
