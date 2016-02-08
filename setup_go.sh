#!/bin/sh

set -e
set -x

url=$1
user=plom
users_home=`su $user -s /bin/sh -c 'echo ~'`

ensure_line() {
    add_string="$1"
    file="$2"
    test=`grep "$add_string" "$file" | wc -l`
    if [ $test -lt 1 ]; then
        echo "$add_string" >> "$file"
    fi
}

filename=temp_golang_binary

if [ "$url" = "" ]; then
    echo 'Need URL of current go package'
    exit 1
fi
rm -rf /usr/local/go
apt-get -y install wget
wget -O $filename $url
tar -C /usr/local -xzf $filename
rm $filename
ensure_line 'export PATH=$PATH:/usr/local/go/bin' $users_home/.shinit_add
ensure_line 'export GOPATH=~/gopath' $users_home/.shinit_add
apt-get -y install vim-pathogen
rm -rf $users_home/.vim/bundle/vim-go
su $user -s 'git clone https://github.com/fatih/vim-go.git ~/.vim/bundle/vim-go'
ensure_line 'source ~/.vimrc_vimgo' $users_home/.vimrc_add
cat << EOF > $users_home/.vimrc_vimgo
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
chown $user $users_home/.vimrc_vimgo
chgrp $user $users_home/.vimrc_vimgo
