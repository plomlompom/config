#!/bin/sh

set -x

dir=~/config/dotfiles
dir_root=~/config/dotfiles_root
homedir=`echo ~`
find ~ -lname $homedir'/config/*' -delete
for file in `ls $dir`; do
    ln -s $dir/$file ~/.$file
done
if [ "$(id -u)" -eq "0" ]; then
    for file in `ls $dir_root`; do
        ln -fs $dir_root/$file ~/.$file
    done
fi
