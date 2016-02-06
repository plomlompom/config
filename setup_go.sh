#!/bin/sh

set -e
set -x

ensure_line() {
    add_string="$1"
    file="$2"
    test=`grep "$add_string" "$file" | wc -l`
    if [ $test -lt 1 ]; then
        echo "$add_string" >> "$file"
    fi
}

filename=temp_golang_binary

if [ "$1" = "" ]; then
    echo 'Need URL of current go package'
    exit 1
fi
sudo rm -rf /usr/local/go
sudo apt-get -y install wget
wget -O $filename $1
sudo tar -C /usr/local -xzf $filename
rm $filename
ensure_line 'export PATH=$PATH:/usr/local/go/bin' ~/.shinit_add
ensure_line 'export GOPATH=~/gopath' ~/.shinit_add
sudo apt-get -y install vim-pathogen
rm -rf ~/.vim/bundle/vim-go
git clone https://github.com/fatih/vim-go.git ~/.vim/bundle/vim-go
ensure_line 'source ~/.vimrc_vimgo' ~/.vimrc_add
cat << EOF > ~/.vimrc_vimgo
" vim-go: Make vim-go run.
call pathogen#infect()
let g:go_disable_autoinstall = 0
" vim-go: Highlight
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
EOF
