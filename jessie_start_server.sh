#!/bin/sh
set -x
set -e

# Set root pw.
passwd

# Post-installation reduction.
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

# Set hostname and FQDN.
echo 'plomlompom' > /etc/hostname
hostname 'plomlompom'
echo '127.0.0.1 localhost' > /etc/hosts
ip=`hostname -I`
echo "$ip plomlompom.com plomlompom" >> /etc/hosts

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
config/bin/symlink.sh

# Add user. Remove old user's config/ if it exists.
useradd -m -s /bin/bash plom
rm /home/plom/.bashrc
rm -rf /home/plom/config
su - plom -c 'git clone http://github.com/plomlompom/config /home/plom/config'
su plom -c '/home/plom/config/bin/symlink.sh server'

# Set up editor.
apt-get -y install vim
mkdir -p .vimbackups
su plom -c 'mkdir -p /home/plom/.vimbackups/'

# Set up ssh-guard.
apt-get -y install sshguard rsyslog

# Set up openssh-server.
apt-get -y install openssh-server

# Set up mail system.
su plom -c 'mkdir -p /home/plom/mail/'
su plom -c 'mkdir -p /home/plom/mail/inbox/{cur,new,tmp}'
su plom -c 'mkdir -p /home/plom/mail/new_inbox/{cur,new,tmp}'
sed -i 's/^delete = true$/delete = false/g' /home/plom/config/dotfiles_user_server/getmail/getmailrc
DEBIAN_FRONTEND=noninteractive apt-get -y install getmail4 procmail mutt postfix maildrop
cp config/systemfiles/main.cf /etc/postfix/main.cf
cp config/systemfiles/aliases /etc/aliases
newaliases
service postfix restart

# Set up regular system update reminder.
apt-get -y install cron
su plom -c "echo '0 18 * * 0 ~/config/bin/simplemail.sh ~/config/mails/update_reminder' | crontab -"

# Set up screen/weechat/OTR/bitlbee. Make bitlbee listen only locally.
apt-get -y install screen weechat-plugins python-potr bitlbee
sed -i 's/^# DaemonInterface/DaemonInterface = 127.0.0.1 # DaemonInterface/' /etc/bitlbee/bitlbee.conf
sedtest=`grep -E '^DaemonInterface = 127.0.0.1 #' /etc/bitlbee/bitlbee.conf | wc -l | cut -d ' ' -f 1`
if [ 0 -eq $sedtest ]; then
    false
fi
cp config/systemfiles/weechat.service  /etc/systemd/system/weechat.service
systemctl enable /etc/systemd/system/weechat.service

# Clean up.
rm jessie_start_server.sh

# Send instructions mail.
config/bin/simplemail.sh config/mails/server_postinstall_finished

# Set password for user.
passwd plom

# Finalize everything with a reboot.
reboot
