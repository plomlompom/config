#!/bin/sh

set -x

dir_minimal=~/config/dotfiles_minimal
dir_user_minimal=~/config/dotfiles_user_minimal
dir_user_thinkpad=~/config/dotfiles_user_thinkpad
dir_user_server=~/config/dotfiles_user_server
dir_root=~/config/dotfiles_root
homedir=`echo ~`
find ~ -lname $homedir'/config/*' -delete
for file in `ls $dir_minimal`; do
    ln -fs $dir_minimal/$file ~/.$file
done
for file in `ls $dir_user_minimal`; do
    ln -fs $dir_user_minimal/$file ~/.$file
done
if [ "$1" = "thinkpad" ]; then
    for file in `ls $dir_user_thinkpad`; do
        ln -fs $dir_user_thinkpad/$file ~/.$file
    done
elif [ "$1" = "server" ]; then
    for file in `ls $dir_user_server`; do
        ln -fs $dir_user_server/$file ~/.$file
    done
fi
if [ "$(id -u)" -eq "0" ]; then
    for file in `ls $dir_root`; do
        ln -fs $dir_root/$file ~/.$file
    done
fi
