#!/bin/sh

# Wait until online.
online=0
while [ $online -eq 0 ]; do
    ping -q -w 1 -c 1 `ip r | grep default | cut -d ' ' -f 3` > /dev/null && \
    online=1 || online=0
done

# Start shell in screen, wait until it's created, then start irssi in it.
screen -d -U -m -S irssi
screen_available=0
while [ $screen_available -eq 0 ]; do
    screen_available=`screen -list | grep irssi | wc -l`
done
screen -S irssi -X stuff 'irssi\n'

# Send mail to remind user to re-identify to NickServ.
~/config/bin/simplemail.sh ~/config/mails/irssi_identify_reminder
