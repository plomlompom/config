#!/bin/sh
set -e

public_repos_dir="${HOME}/public_repos"
config_tree_prefix="${public_repos_dir}/config"
path_borgscript="${config_tree_prefix}/all_new_2018/borg.sh"
config_tree_buster="${config_tree_prefix}/buster"
setup_scripts_dir="${config_tree_buster}/setup_scripts"
repos_list_file="${public_repos_dir}/repos"
dir_secrets="${HOME}/tmp_secrets"
borgkeys_dir=~/.config/borg/keys
borgrepos_file=~/.borgrepos
ssh_dir=~/.ssh
imap_pass_file=.imap_pass

ensure_repo() {
    repo_name="${1}"
    if [ ! -d "${public_repos_dir}/${repo_name}" ]; then
        cd "${public_repos_dir}"
        git clone https://plomlompom.com/repos/clone/${repo_name}
    fi
}

# Clone config to copy dotfiles etc. from it.
cd
mkdir -p "${public_repos_dir}"
ensure_repo config
cd "${setup_scripts_dir}"
./copy_dirtree.sh "${config_tree_buster}/home_files" "${HOME}" minimal user_eeepc

# Set up native messenger for tridactyl.
curl -fsSl https://raw.githubusercontent.com/tridactyl/tridactyl/78e662efefd1f4af2bdb2a53edecf03b535b997b/native/install.sh | bash

# Set up non-public parts of infrastructure.
cd "${dir_secrets}"
mkdir -p "${ssh_dir}"
echo "Setting up .ssh"
cp id_rsa ~/.ssh
stty -echo
ssh-keygen -y -f ~/.ssh/id_rsa > ~/.ssh/id_rsa.pub
stty echo
tar xf borg_keyfiles.tar
mkdir -p "${borgkeys_dir}"
mv borg_keyfiles/* "${borgkeys_dir}"
if [ -f "${imap_pass_file}" ]; then
    cp "${imap_pass_file}" ~
fi
cd
rm -rf "${dir_secrets}"

# Sync org dir via borgbackup. For this we need the borgbackup servers
# in our .ssh/known_hosts file.
cat "${borgrepos_file}" | while read line; do
    first_char=$(echo "${line}" | cut -c1)
    if [ "${first_char}" = "#" ]; then
        continue
    fi
    server=$(echo "${line}" | sed 's/.*@//')
    ssh-keyscan "${server}" >> "${ssh_dir}"/known_hosts
done
BORG_PASSPHRASE="${SECRETS_PASS}" "${path_borgscript}" orgpull

# Fill ~/public_repos.
cat "${repos_list_file}" | while read line; do
    first_char=$(echo "${line}" | cut -c1)
    if [ "${first_char}" = "#" ]; then
        continue
    fi
    ensure_repo "${line}"
done

# Set up e-mail system. Note that we only do mbsync if the imap pass file
# is found. It may not be present on every secrets drive yet, so we have to
# deal with the possibility of it being absent at this point.
mkdir -p ~/Mail/maildir  # expected by mbsync/isync
if [ -f "~/${imap_pass_file}" ]; then
    mbsync -a
fi

# Final note on how to integrate tridactyl.
echo "TODO: As tridactyl user, don't forget to do :source on the first Firefox run and then re-start."
