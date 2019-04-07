#!/bin/sh
set -e

if [ "$#" -ne 1 ]; then
    echo 'Need exactly one argument (hostname).'
    false
fi
hostname="$1"

config_tree_prefix="${HOME}/config/buster"
setup_scripts_dir="${config_tree_prefix}/setup_scripts"
cd "${setup_scripts_dir}"
./setup.sh "${hostname}" ""
./copy_dirtree.sh "${config_tree_prefix}/etc_files" "" eeepc
./install_for_target.sh eeepc

url_firefox="https://ftp.mozilla.org/pub/firefox/releases/66.0/linux-x86_64/en-US/firefox-66.0.tar.bz2"
wget "${url_firefox}"
mv firefox-66.0.tar.bz2 /opt/
cd /opt/
tar xf firefox-66.0.tar.bz2
rm firefox-66.0.tar.bz2
ln -s /opt/firefox/firefox /usr/local/bin/
update-alternatives --install /usr/bin/x-www-browser x-www-browser /opt/firefox/firefox 200
update-alternatives --set x-www-browser /opt/firefox/firefox
cd "${setup_scripts_dir}"

./copy_dirtree.sh "${config_tree_prefix}/home_files" "/root" minimal root
if [ ! -d "/home/plom" ]; then
    adduser --disabled-password --gecos "" plom
    usermod -a -G sudo plom
    su -c "cd && git clone https://plomlompom.com/repos/clone/config" plom
    su -c "~/config/buster/setup_scripts/copy_dirtree.sh ~/config/buster/home_files ~ minimal user_eeepc" plom
    passwd plom
fi
