#!/bin/sh

check_wifi_id_set() {
  if ! echo "${1}" | egrep -q '^[0-9]+$'; then
    echo 'Wifi identifier must be integer.'
    exit 1
  fi
}

print_usage() {
  echo 'Available commands:'
  echo '  eth_connect'
  echo '  eth_disconnect'
  echo '  wifi_scan'
  echo '  wifi_info WIFI_ID'
  echo '  wifi_set_wpa WIFI_ID KEY'
  echo '  wifi_connect WIFI_ID'
  echo '  wifi_disconnect'
}

if ! echo "${1}"; then
  echo 'No command given.'
  print_usage
  exit 1
elif [ "${1}" = 'eth_connect' ]; then
  wicd-cli --wired --connect

elif [ "${1}" = 'eth_disconnect' ]; then
  wicd-cli --wired --disconnect

elif [ "${1}" = 'wifi_scan' ]; then
  wicd-cli --wireless --scan
  wicd-cli --wireless --list-networks

elif [ "${1}" = 'wifi_info' ]; then
  check_wifi_id_set "${2}"
  wicd-cli --wireless --network="${2}" --network-details

elif [ "${1}" = 'wifi_set_wpa' ]; then
  check_wifi_id_set "${2}"
  if ! echo "${3}" ; then
    echo 'No key set.'
    exit 1
  fi
  wicd-cli --wireless --network="${2}" --network-property=enctype --set-to=wpa
  wicd-cli --wireless --network="${2}" --network-property=key --set-to="${3}"

elif [ "${1}" = 'wifi_connect' ]; then
  check_wifi_id_set "${2}"
  wicd-cli --wireless --network="${2}" --connect

elif [ "${1}" = 'wifi_disconnect' ]; then
  wicd-cli --wireless --disconnect

else
  echo 'Unknown command.'
  print_usage
  exit 1
fi
