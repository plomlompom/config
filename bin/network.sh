#!/bin/sh

eth_interface=enp0s25
wifi_interface=wls1

ensure_wifi_on() {
  if [ ! "$(wifi)" = "wifi      = on" ]; then
    wifi on
    ip link set "$wifi_interface" up
  fi
}

print_usage() {
  echo 'Available commands:'
  echo '  eth_connect'
  echo '  eth_disconnect'
  echo '  wifi_scan'
  echo '  wifi_connect_open SSID'
  echo '  wifi_set_wpa SSID KEY'
  echo '  wifi_connect_wep_ascii SSID KEY'
  echo '  wifi_connect_wep_hex SSID KEY'
  echo '  wifi_connect_wpa SSID KEY'
  echo '  wifi_disconnect'
}

if ! echo "${1}"; then
  echo 'No command given.'
  print_usage
  exit 1
elif [ "${1}" = 'eth_connect' ]; then
  ip link set "$eth_interface" up 
  dhclient "$eth_interface"

elif [ "${1}" = 'eth_disconnect' ]; then
  ip link set "$eth_interface" down

elif [ "${1}" = 'wifi_scan' ]; then
  ensure_wifi_on
  ip link set "$wifi_interface" up
  iw dev "$wifi_interface" scan | grep SSID

elif [ "${1}" = 'wifi_connect_open' ]; then
  ensure_wifi_on
  iw dev "$wifi_interface" connect "${2}"
  #dhclient "$wifi_interface" 

elif [ "${1}" = 'wifi_connect_wep_ascii' ]; then
  ensure_wifi_on
  iw dev "$wifi_interface" connect "${2}" key 0:"${3}"
  #dhclient "$wifi_interface" 

elif [ "${1}" = 'wifi_connect_wep_hex' ]; then
  ensure_wifi_on
  iw dev "$wifi_interface" connect "${2}" key d:0:"${3}"
  #dhclient "$wifi_interface" 

elif [ "${1}" = 'wifi_connect_wpa' ]; then
  ensure_wifi_on
  wpa_passphrase "${2}" "${3}" > /tmp/wpa_supplicant.conf
  wpa_supplicant -B -i "$wifi_interface" -c /tmp/wpa_supplicant.conf
  dhclient "$wifi_interface" 

elif [ "${1}" = 'wifi_disconnect' ]; then
  ip link set "$wifi_interface" down

else
  echo 'Unknown command.'
  print_usage
  exit 1
fi
