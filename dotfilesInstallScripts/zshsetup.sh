#!/bin/bash
# Usage:./zshsetup.sh [--offline][--verbose] [--debug]

#Defaults
OFFLINE=no

source "$(dirname $(dirname $0))/libsh/std.sh"
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

	echo
	verbose "**START zshsetup.sh**"


	# Before additon of libsh I was using the variable $OFFLINE so the following is
	# a compatability trick due to use of --offline creating the variable $offline instead of $OFFLINE.
	if expr "$offline" : 'yes' > /dev/null; then
		OFFLINE=yes
	fi

	# Only output cloneing if verbose was passed
	if ! exists $verbose; then
		quiet='--quiet'
	fi

	if expr "$OFFLINE" : 'no' > /dev/null
	then
		verbose "Checing Internet Connection."
		if ping -c 1 1.1.1.1 &> /dev/null; then
			verbose "Set to Online Mode."
		else
			verbose "Cannot Ping 1.1.1.1. Check Your Internet Connection"
			exit 1
		fi

		curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh -s -- --unattended

		for REPO in zsh-syntax-highlighting zsh-autosuggestions; do
			check_file $ZSH_CUSTOM/plugins/$REPO c &> /dev/null || verbose "Cloning sh-users/$REPO"; \
			git clone "$quiet" https://github.com/zsh-users/$REPO.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/$REPO
		done
	fi

	cd $SELF_PARENT

	if expr "$OFFLINE" : 'yes' > /dev/null;
	then
		mkdir -p $OHMYZSH_OFFLINE > /dev/null
		{
			verbose "Set to Offline Mode."

			write $BLUE"Attempting to download/update offline files."$RESET
			wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh --quiet -t 1 && mv install.sh $OHMYZSH_OFFLINE/ohmyzsh_install_orig.sh && verbose "Success, downloaded install script"

			git clone --quiet https://github.com/zsh-users/zsh-syntax-highlighting.git $OHMYZSH_OFFLINE/zsh-syntax-highlighting &> $null && write ${MAGENTA}"Success: zsh-syntax-highlighting"${RESET} || \
			debug "1. git pull" ; cd $OHMYZSH_OFFLINE/zsh-syntax-highlighting && git pull origin master --quiet && cd $SELF_PARENT

			git clone --quiet https://github.com/zsh-users/zsh-autosuggestions.git $OHMYZSH_OFFLINE/zsh-autosuggestions &> $null && write ${MAGENTA}"Success. zsh-autosuggestions"${RESET}  || \
			debug "2. git pull" ; cd $OHMYZSH_OFFLINE/zsh-autosuggestions && git pull origin master --quiet && cd $SELF_PARENT
		} || {
			write $RED"Could not download/update offline files."$RESET
			write $GREEN"Switching to offline files to setup oh-my-zsh."$RESET
		}

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

		write $BLUE"Installing ${BOLD}oh-my-zsh"$RESET
		sh $OHMYZSH_OFFLINE/ohmyzsh_install.sh --unattended $@

		verbose "Copying oh-my-zsh packages to $ZSH_CUSTOM/plugins/."
		cp -r $OHMYZSH_OFFLINE/zsh-syntax-highlighting $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
		cp -r $OHMYZSH_OFFLINE/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions

	fi

	verbose "**FINISH zshsetup.sh**"
	echo
}
main "$@"
