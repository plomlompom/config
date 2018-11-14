#!/bin/sh
# Next setup steps for a server whose login policy has just been set from
# the outside via ./init_user_and_keybased_login.sh.
set -e

# Adapt /etc/ to our needs by symlinking into ./linkable_etc_files. This
# will set basic configurations affecting following steps, such as setup
# of APT and the locale selection, so needs to be right at the beginning.
./symlink_etc.sh all server

# Ensure package installation state as defined by what packages are
# defined as required by Debian policy and by settings in ./apt-mark/.
apt update
./install_for_target.sh all server
./purge_nonrequireds.sh all server

# Only upgrade after reducing the system to the desired minimum, so that
# we don't need to get more data than necessary.
apt -y dist-upgrade

# Set Berlin localtime.
#ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime

# If we have not yet set the shell for user plom, ensure it here. This
# is mostly for convenience.
usermod -s /bin/bash plom
