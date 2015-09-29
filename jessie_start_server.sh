#!/bin/sh
set -x
set -e

# Set root pw.
passwd

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

# Call dhclient on startup.
cat > /etc/systemd/system/dhclient.service << EOF
[Unit]
Description=Ethernet connection

[Service]
ExecStart=/sbin/dhclient eth0

[Install]
WantedBy=multi-user.target
EOF
systemctl enable /etc/systemd/system/dhclient.service

# Package management config, system upgrade.
echo 'deb http://ftp.debian.org/debian/ jessie main contrib non-free' > /etc/apt/sources.list
echo 'deb http://security.debian.org/ jessie/updates main contrib non-free' >> /etc/apt/sources.list
echo 'deb http://ftp.debian.org/debian/ jessie-updates main contrib non-free' >> /etc/apt/sources.list
dhclient eth0
apt-get update
apt-get -y dist-upgrade

# Set up manuals.
apt-get -y install man-db manpages less

# Don't clear boot messages on start up.
sed -i 's/^TTYVTDisallocate=yes$/TTYVTDisallocate=no/g' /etc/systemd/system/getty.target.wants/getty\@tty1.service

# Set up timezone.
echo 'Europe/Berlin' > /etc/timezone
cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime

# Locale config.
apt-get -y install locales
echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
locale-gen

# Clone git repository.
apt-get -y install ca-certificates
apt-get -y install git
git clone http://github.com/plomlompom/config
config/symlink.sh

# Add user. Remove old user's config/ if it exists.
useradd -m -s /bin/bash plom
rm -rf /home/plom/config
su - plom -c 'git clone http://github.com/plomlompom/config /home/plom/config'
su plom -c '/home/plom/config/symlink.sh server'

# Set up editor.
apt-get -y install vim
mkdir -p .vimbackups
su plom -c 'mkdir -p /home/plom/.vimbackups/'

# Set up openssh-server.
apt-get -y install openssh-server

# Set up mail client system.
apt-get -y install getmail4 procmail mutt
su plom -c 'mkdir -p /home/plom/mail'
su plom -c 'mkdir -p /home/plom/mail/inbox/{cur,new,tmp}'

# Set up screen.
apt-get -y install screen

# Set up irssi.
apt-get -y install irssi

# Clean up.
rm jessie_start_server.sh
cat > /etc/systemd/system/irssi.service << EOF
[Unit]
Description=irssi screen

[Service]
Type=forking
User=plom
ExecStart=/bin/sh /home/plom/config/other/screen-irssi.sh

[Install]
WantedBy=multi-user.target
EOF
systemctl enable /etc/systemd/system/irssi.service

# Set password for user.
passwd plom
