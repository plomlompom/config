#!/bin/sh
set -x
set -e

if [ ! "$1" = "thinkpad" ] && [ ! "$1" = "server" ]; then
    echo "Need argument."
    false
fi

if [ "$1" = "thinkpad" ] && [ ! "$2" = "X200s" ] && [ ! "$2" = "T450s" ]; then
    echo "Need Thinkpad type."
    false
fi

if [ "$1" = "server" ] && [ ! "$2" = "plomlompom.com" ] && \
        [ ! "$2" = "test.plomlompom.com" ]; then
    echo "Need server type."
    false
fi

# Some important variables
if [ "$2" = "plomlompom.com" ]; then
    hostname="plomlompom"
elif [ "$2" = "test.plomlompom.com" ]; then
    hostname="test.plomlompom"
elif [ "$2" = "X200s" ]; then
    hostname="X220s"
elif [ "$2" = "T450s" ]; then
    hostname="T450s"
fi

if [ "$1" = "server" ]; then
    # Set root pw.
    passwd
fi

# Post-installation reduction.
dpkg-query -Wf '${Package} ${Priority}\n' | grep ' required' | sed \
    's/ required//' > list_white_unsorted 
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
echo $hostname > /etc/hostname
hostname $hostname
if [ "$1" = "server" ]; then
    echo '127.0.0.1 localhost' > /etc/hosts
    ip=`hostname -I`
    echo "$ip $2 $hostname" >> /etc/hosts

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
fi

# Package management config, system upgrade.
echo 'deb http://ftp.debian.org/debian/ jessie main contrib non-free' \
    > /etc/apt/sources.list
echo 'deb http://security.debian.org/ jessie/updates main contrib non-free' \
    >> /etc/apt/sources.list
echo 'deb http://ftp.debian.org/debian/ jessie-updates main contrib non-free' \
    >> /etc/apt/sources.list
if [ "$1" = "thinkpad" ]; then
    echo 'deb http://ftp.debian.org/debian/ jessie-backports main contrib' \
' non-free' >> /etc/apt/sources.list
    echo 'deb http://ftp.debian.org/debian/ testing main contrib non-free' \
        >> /etc/apt/sources.list
    echo 'deb http://security.debian.org/ testing/updates main contrib' \
' non-free' >> /etc/apt/sources.list
    echo 'deb http://ftp.debian.org/debian/ testing-updates main contrib' \
' non-free' >> /etc/apt/sources.list
    echo 'APT::Default-Release "stable";' \
        >> /etc/apt/apt.conf.d/99defaultrelease
fi
dhclient eth0
apt-get update
apt-get -y dist-upgrade

# Set up manuals.
apt-get -y install man-db manpages less

if [ "$1" = "thinkpad" ]; then
    # Power management as per <http://thinkwiki.de/TLP_-_Linux_Stromsparen>.
    echo '' >> /etc/apt/sources.list
    echo 'deb http://repo.linrunner.de/debian jessie main' \
        >> /etc/apt/sources.list
    apt-key adv --keyserver pool.sks-keyservers.net --recv-keys CD4E8809
    apt-get update
    apt-get -y install linux-headers-amd64 tlp tp-smapi-dkms
    sed -i 's/^#START_CHARGE_THRESH_BAT0/START_CHARGE_THRESH_BAT0=10 '\
'#START_CHARGE_THRESH_BAT0/' /etc/default/tlp
    sed -i 's/^#STOP_CHARGE_THRESH_BAT0/STOP_CHARGE_THRESH_BAT0=95 '\
'#STOP_CHARGE_THRESH_BAT0/' /etc/default/tlp
    sed -i 's/^#DEVICES_TO_DISABLE_ON_STARTUP/DEVICES_TO_DISABLE_ON_STARTUP='\
'"bluetooth wifi wwan" #DEVICES_TO_DISABLE_ON_STARTUP/' /etc/default/tlp
    tlp start
fi

# Don't clear boot messages on start up.
sed -i 's/^TTYVTDisallocate=yes$/TTYVTDisallocate=no/g' \
    /etc/systemd/system/getty.target.wants/getty\@tty1.service

# Set up timezone.
echo 'Europe/Berlin' > /etc/timezone
cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime

# Locale config.
apt-get -y install locales
echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
locale-gen

if [ "$1" = "thinkpad" ]; then
    # Console config.
    DEBIAN_FRONTEND=nointeractive apt-get -y install console-setup
    echo 'ACTIVE_CONSOLES="/dev/tty[1-6]"' > /etc/default/console-setup
    echo 'CHARMAP="UTF-8"' >> /etc/default/console-setup
    echo 'CODESET="Lat15"' >> /etc/default/console-setup
    echo 'FONTFACE="TerminusBold"' >> /etc/default/console-setup
    echo 'FONTSIZE="8x16"' >> /etc/default/console-setup
    echo 'export LC_ALL="en_US.UTF-8"' >> /etc/profile
    sed -i 's/^XKBLAYOUT/XKBLAYOUT="de" # XKBLAYOUT/g' /etc/default/keyboard
    service keyboard-setup restart
fi

# Clone git repository.
apt-get -y install ca-certificates
apt-get -y install git
git clone http://github.com/plomlompom/config
config/bin/symlink.sh

# Add user. Remove old user's config/ if it exists.
useradd -m -s /bin/bash plom
rm -rf /home/plom/config
su - plom -c 'git clone http://github.com/plomlompom/config /home/plom/config'
su plom -c '/home/plom/config/bin/symlink.sh '$1' '$2

# Allow user to sudo.
if [ "$1" = "thinkpad" ]; then
    apt-get -y install sudo
    adduser plom sudo
fi

# Set up editor.
mkdir -p .vimbackups
su plom -c 'mkdir -p /home/plom/.vimbackups/'
apt-get -y install vim

if [ "$1" = "server" ]; then
    # Set up ssh-guard.
    apt-get -y install sshguard rsyslog

    # Set up openssh-server.
    apt-get -y install openssh-server

    # Set up mail system.
    su plom -c 'mkdir -p /home/plom/mail/'
    su plom -c 'mkdir -p /home/plom/mail/inbox/{cur,new,tmp}'
    su plom -c 'mkdir -p /home/plom/mail/new_inbox/{cur,new,tmp}'
    sed -i 's/^delete = true$/delete = false/g' \
        /home/plom/config/dotfiles/user/server/getmail/getmailrc
    DEBIAN_FRONTEND=noninteractive apt-get -y install getmail4 procmail mutt \
        postfix maildrop
    cp config/systemfiles/main.cf /etc/postfix/main.cf
    cp config/systemfiles/aliases /etc/aliases
    newaliases
    service postfix restart

    # Set up regular system update reminder.
    apt-get -y install cron
    su plom -c "echo '0 18 * * 0 ~/config/bin/simplemail.sh '\
        '~/config/mails/update_reminder' | crontab -"

    # Set up screen/weechat/OTR/bitlbee. Make bitlbee listen only locally.
    apt-get -y install screen weechat-plugins python-potr bitlbee
    sed -i 's/^# DaemonInterface/DaemonInterface = 127.0.0.1 '\
'# DaemonInterface/' /etc/bitlbee/bitlbee.conf
    sedtest=`grep -E '^DaemonInterface = 127.0.0.1 #' \
        /etc/bitlbee/bitlbee.conf | wc -l | cut -d ' ' -f 1`
    if [ 0 -eq $sedtest ]; then
        false
    fi
    cp config/systemfiles/weechat.service  /etc/systemd/system/weechat.service
    systemctl enable /etc/systemd/system/weechat.service

    # Send instructions mail.
    config/bin/simplemail.sh config/mails/server_postinstall_finished

elif [ "$1" = "thinkpad" ]; then
    # Set up networking (wifi!).
    apt-get -y install firmware-iwlwifi
    DEBIAN_FRONTEND=noninteractive apt-get -y install wicd-curses
    sed -i 's/^wired_interface = .*$/wired_interface = eth0/g' \
        /etc/wicd/manager-settings.conf
    sed -i 's/^wireless_interface = .*$/wireless_interface = wlan0/g' \
        /etc/wicd/manager-settings.conf
    systemctl restart wicd

    # Set up hibernation on lid close.
    echo 'HandleLidSwitch=hibernate' >> /etc/systemd/logind.conf

    # Set up sound.
    usermod -aG audio plom
    apt-get -y install alsa-utils
    if [ "$2" = "X200s" ]; then
        amixer -c 0 sset Master playback 100% unmute
    elif [ "$2" = "T450s" ]; then
        amixer -c 1 sset Master playback 100% unmute
        # Re-order souncards so the commonly used one is the first one.
        echo 'options snd_hda_intel index=1,0' >> /etc/modprobe.d/sound.conf
    fi

    # Set up window system, i3, redshift.
    apt-get -y install xserver-xorg xinit xterm i3 i3status dmenu redshift

    # Set up OpenGL and hardware acceleration.
    if [ "$2" = "X200s" ]; then
        apt-get -y install i965-va-driver
    elif [ "$2" = "T450s" ]; then
        apt-get -y -t jessie-backports install xserver-xorg-video-intel
    fi
    apt-get -y install libgl1-mesa-dri
    usermod -aG video plom

    # Install xrandr.
    apt-get -y install x11-xserver-utils

    # Set up pentadactyl. 
    apt-get -y install iceweasel
    apt-get -y -t jessie-backports install xul-ext-pentadactyl
    apt-get -y install vim-gtk
    su plom -c 'mkdir -p /home/plom/downloads/'

    # Set up openssh-client.
    apt-get -y install openssh-client
fi

# Set password for user.
passwd plom

# Clean up.
rm jessie_postinstall.sh

# Finalize everything with a reboot.
reboot
