#!/bin/bash

#if [[ $EUID -ne 0 ]]; then
#   echo "This script must be run as root"
#   exit 1
#fi

# Added `microsoft` due to `uname -v` returning `#836-Microsoft Mon May 05 16:04:00 PST 2020` on a WSL version.
version=$(uname -v)
debbased=$(echo $version | grep -Pio "(debian|ubuntu|microsoft)")
if [[ "$debbased" = "Debian" ]] || [[ "$debbased" = "Microsoft" ]] || [[ "$debbased" = "Ubuntu" ]]
then
	#apt update
	#apt install vim fonts-powerline exuberant-ctags -y
	exit 0
	echo "Please Run the following:"
	echo "apt update"
	echo "apt install vim fonts-powerline exuberant-ctags -y"
	exit 1

else
	#pacman -S awesome-terminal-fonts noto-fonts noto-fonts-extra powerline-fonts ctags flake8
	echo "Please run  the following:"
	echo "pacman -S awesome-terminal-fonts noto-fonts noto-fonts-extra powerline-fonts ctags flake8"
	
fi
