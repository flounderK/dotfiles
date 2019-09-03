#!/bin/bash

echo "Installing Vundle"
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

version=$(uname -v)
debbased=$(echo $version | grep -Pio "(debian|ubuntu)")
if [[ ! -z "$debbased" ]]
then
	apt update 
	apt install fonts-powerline
fi


