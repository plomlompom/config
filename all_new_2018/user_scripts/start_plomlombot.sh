#!/bin/sh
set -e
cd ~/plomlombot-irc
./run.sh -r 604800 -n "$1" "$2"
