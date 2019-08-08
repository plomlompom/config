#!/bin/sh
set -e

if [ "$#" -ne 1 ]; then
    echo 'Need exactly one argument (hostname).'
    false
fi
hostname="$1"

# Set up system without user environment.
config_tree_prefix="${HOME}/config/buster"
setup_scripts_dir="${config_tree_prefix}/setup_scripts"
cd "${setup_scripts_dir}"
./setup.sh "${hostname}" ""
./copy_dirtree.sh "${config_tree_prefix}/etc_files" "" eeepc
./install_for_target.sh eeepc

# Install Firefox directly from Mozilla.
firefox_release="68.0esr"
firefox_filename="firefox-${firefox_release}.tar.bz2"
url_firefox="https://ftp.mozilla.org/pub/firefox/releases/${firefox_release}/linux-x86_64/en-US/${firefox_filename}"
wget "${url_firefox}"
mv "${firefox_filename}" /opt/
cd /opt/
tar xf "${firefox_filename}"
rm "${firefox_filename}"
ln -s /opt/firefox/firefox /usr/local/bin/
update-alternatives --install /usr/bin/x-www-browser x-www-browser /opt/firefox/firefox 200
update-alternatives --set x-www-browser /opt/firefox/firefox

# Install Firefox plugins.
# See <https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/Distribution_options/Sideloading_add-ons>
extensions_dir="/usr/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}/"
mkdir -p "${extensions_dir}"
umatrix_xpi="uMatrix.firefox.signed.xpi"
url_umatrix="https://github.com/gorhill/uMatrix/releases/download/1.3.17rc4/${umatrix_xpi}"
wget "${url_umatrix}"
name=$(unzip -p "${umatrix_xpi}" manifest.json | jq -r .applications.gecko.id)
mv "${umatrix_xpi}" "${name}"
#noscript_xpi="noscript-11.0.2.xpi"
#url_noscript="https://secure.informaction.com/download/releases/${noscript_xpi}"
#wget "${url_noscript}"
#name=$(unzip -p "${noscript_xpi}" manifest.json | jq -r .applications.gecko.id)
#mv "${noscript_xpi}" "${name}.xpi"
tridactyl_xpi="tridactyl-latest.xpi"
url_tridactyl="https://tridactyl.cmcaine.co.uk/betas/${tridactyl_xpi}"
wget "${url_tridactyl}"
name=$(unzip -p "${tridactyl_xpi}" manifest.json | jq -r .applications.gecko.id)
mv "${tridactyl_xpi}" "${name}.xpi"
mv *.xpi "${extensions_dir}"

# Set up user environments.
secrets_dev="sdb"
source_dir_secrets="/media/${secrets_dev}/to_usb"
target_dir_secrets="/home/plom/tmp_secrets"
cd "${setup_scripts_dir}"
./copy_dirtree.sh "${config_tree_prefix}/home_files" "/root" minimal root
HOME_DIR_EXISTS=$([ ! -d "/home/plom" ]; echo $?)
adduser --disabled-password --gecos "" plom
usermod -a -G sudo plom
passwd plom
if [ "${HOME_DIR_EXISTS}" -eq 0 ]; then
    echo "Put secrets drive into slot for /dev/${secrets_dev}."
    while [ ! -e /dev/"${secrets_dev}" ]; do
        sleep 1
    done
    stty -echo
    printf "Secrets passphrase: "
    read secrets_pass
    stty echo
    echo "" # newline so user knows their input return was accepted
    echo "${secrets_pass}" | pmount /dev/"${secrets_dev}"
    cp -a "${source_dir_secrets}" "${target_dir_secrets}"
    chown -R plom:plom "${target_dir_secrets}"
    pumount "${secrets_dev}"
    echo "You can remove /dev/${secrets_dev} now."
    cp setup_home_eeepc.sh /home/plom
    chown plom:plom /home/plom/setup_home_eeepc.sh
    SECRETS_PASS="${secrets_pass}" su -c "cd && ./setup_home_eeepc.sh" plom
fi
