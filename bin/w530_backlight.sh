#!/bin/sh

# A very primitive backlight setter with a hardcoded backlight path, to replace
# xbacklight which currently does not work on my system.

if ! echo "${1}" | egrep -q '^[0-9]+$' && ! [ "${1}" = "+" -o "${1}" = "-" ]; then
  echo 'Argument must be a number, or "+", or "-".'
  exit 1
fi
backlight_dir=/sys/class/backlight/intel_backlight
max_brightness=$(cat "${backlight_dir}"/max_brightness)
target="${backlight_dir}"/brightness
fract=$(expr "${max_brightness}" / 100)
if [ "${1}" = "+" -o "${1}" = "-" ]; then
  cur_brightness=$(cat "${backlight_dir}"/brightness)
  brightness=$(expr "${cur_brightness}" "${1}" "${fract}")
  if [ "${brightness}" -gt "${max_brightness}" ]; then
    brightness="${max_brightness}"
  elif [ "${brightness}" -lt "0" ]; then
    brightness=0
  fi
  sudo sh -c 'echo '"${brightness}"' > '"${target}"
  exit 0
fi
percentage=${1}
if [ "${percentage}" = '100' ]; then
  sudo sh -c 'echo '"${max_brightness}"' > '"${target}"
else
  brightness=$(expr "${percentage}" \* "${fract}")
  sudo sh -c 'echo '"${brightness}"' > '"${target}"
fi
