#!/bin/sh

set -x

dir_minimal=~/config/dotfiles/minimal
dir_user_minimal=~/config/dotfiles/user/minimal
dir_user_thinkpad=~/config/dotfiles/user/thinkpad
dir_user_X200s=~/config/dotfiles/user/x200s
dir_user_T450s=~/config/dotfiles/user/t450s
dir_user_server=~/config/dotfiles/user/server
dir_root=~/config/dotfiles/root
homedir=`echo ~`
find ~ -lname $homedir'/config/*' -delete
for file in `ls $dir_minimal`; do
    ln -fs $dir_minimal/$file ~/.$file
done
if [ "$(id -u)" -eq "0" ]; then
    for file in `ls $dir_root`; do
        ln -fs $dir_root/$file ~/.$file
    done
else
    for file in `ls $dir_user_minimal`; do
        ln -fs $dir_user_minimal/$file ~/.$file
    done
    if [ "$1" = "thinkpad" ]; then
        for file in `ls $dir_user_thinkpad`; do
            ln -fs $dir_user_thinkpad/$file ~/.$file
        done
        if [ "$2" = "X200s" ]; then
            for file in `ls $dir_user_X200s`; do
                ln -fs $dir_user_X200s/$file ~/.$file
            done
        else
            for file in `ls $dir_user_T450s`; do
                ln -fs $dir_user_T450s/$file ~/.$file
            done
        fi
    elif [ "$1" = "server" ]; then
        for file in `ls $dir_user_server`; do
            ln -fs $dir_user_server/$file ~/.$file
        done
    fi
fi
