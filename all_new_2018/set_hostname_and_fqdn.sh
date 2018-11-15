#!/bin/sh
# Sets hostname and optionally FQDN.
#
# Calls hostname, writes to /etc/hostname and /etc/hosts. For /etc/hosts
# writing follows recommendations from Debian manual at
# <https://www.debian.org/doc/manuals/debian-reference/ch05.en.html>
# (section "The hostname resolution") on how to map hostname and possibly
# FQDN to a permanent IP if present (we assume here any non-private IP
# and non-loopback IP returned by hostname -I to fulfill that criterion
# on our systems) or to 127.0.1.1 if not. On the reasoning for separating
# localhost and hostname mapping to different IPs, see
# <https://unix.stackexchange.com/a/13087>.
set -e

hostname="$1"
fqdn="$2"
if [ "${hostname}" = "" ]; then
    echo "Need hostname as argument."
    false
fi

echo "${hostname}" > /etc/hostname
hostname "${hostname}"

final_ip="127.0.1.1"
for ip in $(hostname -I); do
    range_1=$(echo "${ip}" | cut -d "." -f 1)
    range_2=$(echo "${ip}" | cut -d "." -f 2)
    if [ "${range_1}" -eq 127 ]; then
        continue
    elif [ "${range_1}" -eq 10 ]; then
        continue
    elif [ "${range_1}" -eq 172 ]; then
        if [ "${range_2}" -ge 16 ] && [ "${range_2}" -le 31 ]; then
            continue
        fi
    elif [ "${range_1}" -eq 192 ]; then
        if [ "${range_2}" -eq 168 ]; then
            continue
        fi
    fi
    echo 'SETTING' $ip
    final_ip="${ip}"
done
echo "127.0.0.1 localhost.localdomain localhost" > /etc/hosts
echo "${final_ip} ${fqdn} ${hostname}" >> /etc/hosts
