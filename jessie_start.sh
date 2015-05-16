#!/bin/sh
set -x
set -e

# Post-installation reduction. (Answer "no" to GRUB question.)
dpkg-query -Wf '${Package} ${Priority}\n' | grep ' required' | sed 's/ required//' > list_white_unsorted 
echo 'ifupdown' >> list_white_unsorted 
echo 'isc-dhcp-client' >> list_white_unsorted
sort list_white_unsorted > list_white
dpkg-query -Wf '${Package}\n' > list_all_packages
sort list_all_packages > foo
mv foo list_all_packages
comm -3 list_all_packages list_white > list_black
apt-mark auto `cat list_black`
echo 'APT::AutoRemove::RecommendsImportant "false";' > /etc/apt/apt.conf.d/99mindeps
echo 'APT::AutoRemove::SuggestsImportant "false";' >> /etc/apt/apt.conf.d/99mindeps 
DEBIAN_FRONTEND=noninteractive apt-get -y --purge autoremove
rm list_all_packages list_white_unsorted list_white list_black 
echo 'APT::Install-Recommends "false";' >> /etc/apt/apt.conf.d/99mindeps
echo 'APT::Install-Suggests "false";' >> /etc/apt/apt.conf.d/99mindeps

# Package management config, system upgrade.
echo 'deb http://ftp.debian.org/debian/ jessie main contrib non-free' > /etc/apt/sources.list
echo 'deb http://security.debian.org/ jessie/updates main contrib non-free' >> /etc/apt/sources.list
echo 'deb http://ftp.debian.org/debian/ jessie-updates main contrib non-free' >> /etc/apt/sources.list
dhclient eth0
apt-get update
apt-get -y dist-upgrade

# Power management as per <http://thinkwiki.de/TLP_-_Linux_Stromsparen>.
echo '' >> /etc/apt/sources.list
echo 'deb http://repo.linrunner.de/debian jessie main' >> /etc/apt/sources.list
apt-key adv --keyserver pool.sks-keyservers.net --recv-keys CD4E8809
apt-get update
apt-get -y install linux-headers-amd64 tlp tp-smapi-dkms
sed -i 's/^#START_CHARGE_THRESH_BAT0/START_CHARGE_THRESH_BAT0=10 #START_CHARGE_THRESH_BAT0/' /etc/default/tlp
sed -i 's/^#STOP_CHARGE_THRESH_BAT0/START_CHARGE_THRESH_BAT0=10 #STOP_CHARGE_THRESH_BAT0/' /etc/default/tlp
sed -i 's/^#DEVICES_TO_DISABLE_ON_STARTUP/DEVICES_TO_DISABLE_ON_STARTUP="bluetooth wifi wwan" #DEVICES_TO_DISABLE_ON_STARTUP/' /etc/default/tlp
tlp start

# Don't clear boot messages on start up.
sed -i 's/^TTYVTDisallocate=yes$/TTYVTDisallocate=no/g' /etc/systemd/system/getty.target.wants/getty\@tty1.service

# Console config.
DEBIAN_FRONTEND=nointeractive apt-get -y install locales console-setup
echo 'ACTIVE_CONSOLES="/dev/tty[1-6]"' > /etc/default/console-setup
echo 'CHARMAP="UTF-8"' >> /etc/default/console-setup
echo 'CODESET="Lat15"' >> /etc/default/console-setup
echo 'FONTFACE="TerminusBold"' >> /etc/default/console-setup
echo 'FONTSIZE="8x16"' >> /etc/default/console-setup
echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
locale-gen
echo 'export LC_ALL="en_US.UTF-8"' >> /etc/profile

# Clone git repository.
apt-get -y install ca-certificates
apt-get -y install git
git clone http://github.com/plomlompom/config
config/symlink.sh

# Add user. Remove old user's config/ if it exists.
useradd -m -s /bin/bash plom
rm -rf /home/plom/config
su - plom -c 'git clone http://github.com/plomlompom/config /home/plom/config'
su plom -c /home/plom/config/symlink.sh

# Set up window system.
apt-get -y install xserver-xorg xinit xterm i3 i3status dmenu

# Set up manuals.
apt-get -y install man-db manpages less

# Set up editor.
apt-get -y install vim
mkdir -p .vimbackups
su plom -c 'mkdir -p /home/plom/.vimbackups/'

# Set up pentadactyl. 
apt-get -y install xul-ext-pentadactyl

# Clean up.
rm jessie_start.sh

# Set password for user.
passwd plom
