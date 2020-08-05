#!/bin/bash
# Usage:./zshsetup.sh [--offline][--verbose] [--debug]

#Defaults
OFFLINE=no

source ../libsh/std.sh
make_sh_macos_compatible

#Setup Variables
PWD=$(pwd)
SELF=$(realpath $0)
SELF_PARENT=$(realpath $(dirname $0))
null=/dev/null

SCRIPTS=$(realpath $SELF_PARENT/../dotfilesInstallScripts)
OHMYZSH_OFFLINE=$(realpath $SELF_PARENT/../ohmyzsh_offline)
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

main() {
	param switch offline $@
	param switch verbose $@
	param switch v $@
	param switch debug $@
	param switch d $@

	setup_color override

	verbose "**START zshsetup.sh**\n"

	if expr "$offline" : 'yes' > /dev/null; then
		OFFLINE=yes
	fi


	if expr "$OFFLINE" : 'no' > /dev/null
	then
		verbose "Set to Online Mode."
		curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh -s -- --unattended || OFFLINE=yes
		git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting || OFFLINE=yes

		git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions || OFFLINE=yes
	fi

	cd $SELF_PARENT

	if expr "$OFFLINE" : 'yes' > /dev/null;
	then
		mkdir -p $OHMYZSH_OFFLINE > /dev/null
		{
			verbose "$(basename $0) - Set to Offline Mode."
			#echo "PWD:"$RED"$(pwd)"$RESET
			write $YELLOW"Attempting to download/update offline files."$RESET
			wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh --quiet -t 1 && mv install.sh $OHMYZSH_OFFLINE/ohmyzsh_install_orig.sh
			#echo "PWD:"$RED"$(pwd)"$RESET
			git clone --quiet https://github.com/zsh-users/zsh-syntax-highlighting.git $OHMYZSH_OFFLINE/zsh-syntax-highlighting > $null || debug "1. git pull" ; cd $OHMYZSH_OFFLINE/zsh-syntax-highlighting && git pull --quiet && cd $SELF_PARENT
			#echo "PWD:"$RED"$(pwd)"$RESET
			git clone --quiet https://github.com/zsh-users/zsh-autosuggestions.git $OHMYZSH_OFFLINE/zsh-autosuggestions > $null || debug "2. git pull" ; cd $OHMYZSH_OFFLINE/zsh-autosuggestions && git pull --quiet && cd $SELF_PARENT
		} || { 
			write $RED"Could not download/update offline files."
			write $GREEN"Switching to offline files to setup oh-my-zsh."$RESET
		}
		#echo "PWD:"$RED"$(pwd)"$RESET

		cd $SELF_PARENT
		
		verbose "Checking if Files Exist."
		for i in $SCRIPTS/ohmyzsh_install.sh $OHMYZSH_OFFLINE/zsh-syntax-highlighting $OHMYZSH_OFFLINE/zsh-autosuggestions
		do
			if ! check_file $i c; then
				error "Please Run with an Internet Connection to Download Nessesary Files."
			fi
		done

		cd $SELF_PARENT

		verbose "Copying ohmyzsh_install.sh to offline directory."
		cp $SCRIPTS/ohmyzsh_install.sh $OHMYZSH_OFFLINE

		verbose "Making ohmysh_install.sh executable."
		chmod +x $OHMYZSH_OFFLINE/ohmyzsh_install.sh
		
		write $GREEN"Installing ${BOLD}oh-my-zsh"$RESET
		
		#write $BOLD"$(date)"${RESET}
		sh $OHMYZSH_OFFLINE/ohmyzsh_install.sh --unattended $@
		#write $BOLD"$(date)"${REST}
		
		verbose "Copying oh-my-zsh packages to $ZSH_CUSTOM/plugins/."
		cp -r $OHMYZSH_OFFLINE/zsh-syntax-highlighting $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
		cp -r $OHMYZSH_OFFLINE/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions

	fi

	verbose "**FINISH zshsetup.sh**\n"
}
main "$@"
