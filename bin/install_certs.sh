#!/bin/sh

set -e
set -x

~/letsencrypt/letsencrypt-auto certonly --standalone -d dump.plomlompom.com
