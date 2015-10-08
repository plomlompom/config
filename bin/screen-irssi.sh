#!/bin/sh

# Wait until online.
online=0
while [ $online -eq 0 ]; do
    ping -q -w 1 -c 1 `ip r | grep default | cut -d ' ' -f 3` > /dev/null && \
    online=1 || online=0
done
echo 1

# Start irssi in shell in screen.
screen -d -m -S irssi
screen -S irssi -X stuff 'irssi\n'
