#!/bin/sh

dir=~/config/dotfiles
cd ~
for file in $dir; do
    ln -s $dir/$file ~/.$file
done
