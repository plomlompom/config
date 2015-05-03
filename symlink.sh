#!/bin/sh

dir=~/config/dotfiles
cd ~
for file in `ls $dir`; do
    ln -s $dir/$file ~/.$file
done
