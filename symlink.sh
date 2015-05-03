#!/bin/sh

dir=~/config/dotfiles
dir_root=~/config/dotfiles_root
for file in `ls $dir`; do
    ln -fs $dir/$file ~/.$file
done
if [ "$(id -u)" -ne "0" ]; then
    for file in `ls $dir_root`; do
        ln -fs $dir_root/$file ~/.$file
    done
fi
