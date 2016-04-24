#!/bin/sh

set -e
set -x

~/letsencrypt/letsencrypt-auto certonly --standalone -d dump.plomlompom.com
~/letsencrypt/letsencrypt-auto certonly --standalone -d htwtxt.plomlompom.com 
