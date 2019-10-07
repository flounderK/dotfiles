#!/bin/bash

echo "Installing Vundle"
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

version=$(uname -v)
debbased=$(echo $version | grep -Pio "(debian|ubuntu)")
if [[ ! -z "$debbased" ]]
then
	apt update 
	apt install fonts-powerline
	exit 0
fi

pacman -S awesome-terminal-fonts noto-fonts noto-fonts-extra powerline-fonts 
