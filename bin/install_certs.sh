#!/bin/sh

set -e
set -x

~/letsencrypt/letsencrypt-auto certonly --webroot -w /var/www/html -d dump.plomlompom.com
