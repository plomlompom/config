#!/bin/sh

dir=~/config/dotfiles
cd ~
for file in `ls $dir`; do
    ln -fs $dir/$file ~/.$file
done
