#!/bin/sh
set -e

# Provide maximum input for set_hostname_and_fqdn.sh.
if [ "$#" -ne 2 ]; then
    echo 'Need exactly two arguments (hostname, FQDN).'
    false
fi
hostname="$1"
fqdn="$2"

config_tree_prefix="${HOME}/config/buster"
setup_scripts_dir="${config_tree_prefix}/setup_scripts"
cd "${setup_scripts_dir}"

# Adapt /etc/ to our needs by hardlinking into ./linkable_etc_files. This
# will set basic configurations affecting following steps, such as setup
# of APT and the locale selection, so needs to be right at the beginning.
./copy_etc.sh all

# Set hostname and FQDN.
./set_hostname_and_fqdn.sh "${hostname}" "${fqdn}"

# Some debconf selections we don't want to get asked during coming
# install actions.
echo 'libc6:amd64 libraries/restart-without-asking boolean true' | debconf-set-selections

# Ensure package installation state as defined by what packages are
# defined as required by Debian policy and by settings in ./apt-mark/.
apt update
./install_for_target.sh all
./purge_nonrequireds.sh all

# Ensure our desired locale is available.
locale-gen

# Only upgrade after reducing the system to the desired minimum, so that
# we don't need to get more data than necessary.
apt -y dist-upgrade

# Set Berlin localtime.
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
