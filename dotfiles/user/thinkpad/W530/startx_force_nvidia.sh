#!/bin/sh

# Undo bumblebee setup.
sudo service bumblebeed stop
sudo modprobe nvidia-drm
sudo update-alternatives --set glx /usr/lib/nvidia

# Use special xorg.conf and pass NVIDIA_DIRECT directive to .xinitrc.
NVIDIA_DIRECT=1 startx -- -config xorg.conf.forced_nvidia

# Recreate bumblebee setup.
sudo service bumblebeed start
sudo update-alternatives --auto glx 
