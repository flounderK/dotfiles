#!/bin/bash
# Usage: ./setup.sh [--offline] [-v|--verbose]
#
# Description: Setup dotfiles with defaults, this will install vim,zsh, dependencies, and oh-my-zsh.
#				and install the default plugins.

# Defaults
OFFLINE=no
VERBOSE=no

if [ ! -x libsh/std.sh ];then
	echo "setup.sh: Error: libsh/std.sh Does Not Exist or is Not Executable."
	echo "setup.sh: Try running 'git submodule init && git submodule update'."
	exit 1
fi

source libsh/std.sh
make_sh_macos_compatible

#Variables
PWD=$(pwd)
SELF=$(realpath $0)
SELF_PARENT=$(realpath $(dirname $0))
SCRIPTS=$(realpath $SELF_PARENT/dotfilesInstallScripts)
VIM_OFFLINE=$(realpath $SELF_PARENT/vim_offline)
ZSH_OFFLINE=$(realpath $SELF_PARENT/ohmyzsh_offline)

main() {
	param switch offline $@
	param switch OFFLINE $@
	param switch verbose $@
	param switch v $@
	param switch debug $@
	param switch d $@

	if expr "$offline" : 'yes' > /dev/null; then
		OFFLINE=yes
	fi

	need_root
	setup_color override

	verbose "Checking for existence of $SCRIPTS"
	check_file $SCRIPTS

	verbose "Making Scripts Executable"
	for i in $(ls $SCRIPTS); do
		chmod +x $SCRIPTS/$i
	done

	# Run Dependencies
	write ${BLUE}"Installing Dependencies"${RESET}
	bash $SCRIPTS/vim_deps.sh
	bash $SCRIPTS/zsh_deps.sh

	if expr "$OFFLINE" : 'yes' > /dev/null && check_file $VIM_OFFLINE/bundle c &>/dev/null ; then

		verbose "Copying Offline vim Plugins to ~/.vim/bundle"
		mkdir -p ~/.vim
		cp -r $VIM_OFFLINE/bundle ~/.vim
		if [ -d ~/.vim/bundle ]; then
			verbose $GREEN"Sucess."$RESET
		fi
	fi

	# Run ohmyzsh setup depending on offline switch.
	bash $SCRIPTS/zshsetup.sh $@

	#Install Dotfiles
	write ${BLUE}"Running update_dotfiles.py"${RESET}
	check_file $SELF_PARENT/update_dotfiles.py
	for dot in .zshrc .vimrc .tmux.conf; do
		python3 $SELF_PARENT/update_dotfiles.py --install -f $dot
	done
	cd $SELF_PARENT

	write ${BLUE}"Opening vim."${RESET}
	vim

	# make python interactive tab complete work
	echo 'export PYTHONSTARTUP="~/.pythonstartup.py"' >> ~/.bashrc

	if expr "$OFFLINE" : 'yes' > /dev/null; then
		verbose "Storing Offline vim Plugins to $VIM_OFFLINE/bundle"
		mkdir -p $VIM_OFFLINE
		check_file  ~/.vim/bundle && cp -r ~/.vim/bundle $VIM_OFFLINE/bundle
	fi

	write ${BLUE}"Setting zsh as the default shell."${RESET}
	sudo chsh -s /usr/bin/zsh
	write ${BLUE}${BOLD}"DONE."${RESET}

}

main "$@"
