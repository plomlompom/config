#!/bin/sh
set -x

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
apt-get -y --purge autoremove
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

# Don't clear boot messages on start up.
sed -i 's/^TTYVTDisallocate=yes$/TTYVTDisallocate=no/g' /etc/systemd/system/getty.target.wants/getty\@tty1.service

# Console config. (locales: 146, 1; console-setup: 27, 11, 1, 4)
apt-get -y install locales console-setup
dpkg-reconfigure locales
dpkg-reconfigure console-setup
echo 'export LC_ALL="en_US.UTF-8"' >> /etc/profile
apt-get -y install xserver-xorg xinit i3

# Install certificates.
apt-get -y install ca-certificates

# Set up window system.
apt-get -y install xserver-xorg xinit i3 i3status

# Add user.
#useradd -m -s /bin/bash plom
