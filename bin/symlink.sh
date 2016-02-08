#!/bin/sh

set -x
set -e

dir_minimal=~/config/dotfiles/minimal
dir_user_prefix=~/config/dotfiles/user
dir_user_minimal=$dir_user_prefix/minimal
dir_user_machine=$dir_user_prefix/$1/minimal
if [ "$3" = "" ]; then
    dir_user_variety=$dir_user_machine/$2
else
    dir_user_variety=$dir_user_machine/$2/minimal
fi
dir_user_subvariety=$dir_user_variety/$3
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
    for file in `ls $dir_user_machine`; do
        ln -fs $dir_user_machine/$file ~/.$file
    done
    for file in `ls $dir_user_variety`; do
        ln -fs $dir_user_variety/$file ~/.$file
    done
    if [ ! "$3" = "" ]; then
        for file in `ls $dir_user_subvariety`; do
            ln -fs $dir_user_subvariety/$file ~/.$file
        done
    fi
fi
