#!/bin/sh
# A very primitive backlight setter with a hardcoded backlight path, to replace
# xbacklight which currently does not work on my system.
if ! echo "${1}" | egrep -q '^[0-9]+$'; then
  echo 'Argument must be a number.'
  exit 1
fi
percentage=${1}
backlight_dir=/sys/class/backlight/intel_backlight
max_brightness=$(cat "${backlight_dir}"/max_brightness)
if [ "${percentage}" = '100' ]; then
  sudo sh -c 'echo '"${max_brightness}"' > '"${backlight_dir}"'/brightness'
else
  fract=$(expr "${max_brightness}" / 100)
  brightness=$(expr "${percentage}" \* "${fract}")
  sudo sh -c 'echo '"${brightness}"' > '"${backlight_dir}"'/brightness'
fi
