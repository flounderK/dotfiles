#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

version=$(uname -v)
debbased=$(echo $version | grep -Pio "(debian|ubuntu)")
if [[ ! -z "$debbased" ]]
then
	apt update 
	apt install zsh
	exit 0
fi

pacman -S zsh
