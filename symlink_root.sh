#!/bin/sh

dir=~/config/dotfiles_root
cd ~
for file in `ls $dir`; do
    ln -fs $dir/$file ~/.$file
done
