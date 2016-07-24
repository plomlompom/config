#!/bin/sh

service nginx stop
~/letsencrypt/letsencrypt-auto renew
service nginx restart
