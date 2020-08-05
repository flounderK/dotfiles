#!/bin/sh
#
# This script should be run via curl:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# or wget:
#   sh -c "$(wget -qO- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
#
# As an alternative, you can first download the install script and run it afterwards:
#   wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
#   sh install.sh
#
# You can tweak the install behavior by setting variables when running the script. For
# example, to change the path to the Oh My Zsh repository:
#   ZSH=~/.zsh sh install.sh
#
# Respects the following environment variables:
#   ZSH     - path to the Oh My Zsh repository folder (default: $HOME/.oh-my-zsh)
#   REPO    - name of the GitHub repo to install from (default: ohmyzsh/ohmyzsh)
#   REMOTE  - full remote URL of the git repo to install (default: GitHub via HTTPS)
#   BRANCH  - branch to check out immediately after install (default: master)
#
# Other options:
#   CHSH       - 'no' means the installer will not change the default shell (default: yes)
#   RUNZSH     - 'no' means the installer will not run zsh after the install (default: yes)
#   KEEP_ZSHRC - 'yes' means the installer will not replace an existing .zshrc (default: no)
#
# You can also pass some arguments to the install script to set some these options:
#   --skip-chsh: has the same behavior as setting CHSH to 'no'
#   --unattended: sets both CHSH and RUNZSH to 'no'
#   --keep-zshrc: sets KEEP_ZSHRC to 'yes'
#	--offline: downloads needed file to install on an air gapped system (offline)
#	--verbose: verbose output.
# For example:
#   sh install.sh --unattended
#
set -e

make_sh_macos_compatible() {
    if expr "$OSTYPE" : 'darwin' > /dev/null; then
        realpath() { 
            { case $1 in "/"*) true;; *) false;; esac; } && echo "$1" || echo "$PWD/${1#./}" 
        }
    fi
}
make_sh_macos_compatible

# Default settings
ZSH=${ZSH:-~/.oh-my-zsh}
REPO=${REPO:-ohmyzsh/ohmyzsh}
REMOTE=${REMOTE:-https://github.com/${REPO}.git}
BRANCH=${BRANCH:-master}
PWD=${PWD:-$(pwd)}
SELF=$(realpath $0)
SELF_PARENT=$(realpath $(dirname $0))
OFFLINE_DIR=${OFFLINE_DIR:-$(realpath $SELF_PARENT/ohmyzsh)}

# Other options
CHSH=${CHSH:-yes}
RUNZSH=${RUNZSH:-yes}
KEEP_ZSHRC=${KEEP_ZSHRC:-no}
OFFLINE=${OFFLINE:-no}
VERBOSE=${VERBOSE:-no}

setup_color() {
        # Only use colors if connected to a terminal, unless override is passed.
        override=$1
        if [ -t 1 ] || [ ! -z "$override" ] ; then
                RED=$(printf '\033[31m')
                GREEN=$(printf '\033[32m')
                YELLOW=$(printf '\033[33m')
                BLUE=$(printf '\033[34m')
                MAGENTA=$(printf '\033[95m')
                CYAN=$(printf '\033[36m')
                BOLD=$(printf '\033[1m')
                ITALIC=$(printf '\033[3m')
                RESET=$(printf '\033[m')
                WARNING=$(printf '\033[93m')
                HEADER=$(printf '\033[95m')
                UNDERLINE=$(printf '\033[4m')

        else
                RED=""
                GREEN=""
                YELLOW=""
                BLUE=""
                BOLD=""
                RESET=""
        fi
}

setup_color

error() {
        echo ${BOLD}"$(basename $0):${RESET}${RED} Error   --> ${BOLD}$@"${RESET} >&2
}

verbose() {
    for i in $verbose $VERBOSE $v $V; do
        if expr match $i 'yes' > /dev/null; then
            echo ${BOLD}"$(basename $0):${RESET}${YELLOW} Verbose --> "${BOLD}"$@"${RESET}
            return
        fi
    done
}

debug() {
    for i in $debug $DEBUG $d $D; do
        if expr match $i 'yes' > /dev/null; then
            echo ${BOLD}"$(basename $0):${RESET}${CYAN} Debug   --> "${BOLD}"$@"${RESET}
            return
        fi
    done
}

write() {
        echo $BOLD"$(basename $0):${RESET} $@"
}

command_exists() {
        command -v "$@" >/dev/null 2>&1
}

beginswith() { case $2 in "$1"*) true;; *) false;; esac; }

checkresult() { if [ $? = 0 ]; then echo TRUE; else echo FALSE; fi; }

exists() { if [ ! -z $1 ]; then true; else false; fi; }


setup_ohmyzsh() {
	# Prevent the cloned repository from having insecure permissions. Failing to do
	# so causes compinit() calls to fail with "command not found: compdef" errors
	# for users with insecure umasks (e.g., "002", allowing group writability). Note
	# that this will be ignored under Cygwin by default, as Windows ACLs take
	# precedence over umasks except for filesystems mounted with option "noacl".
	umask g-w,o-w

	command_exists git || {
		error "git is not installed"
		exit 1
	}

	if [ "$OSTYPE" = cygwin ] && git --version | grep -q msysgit; then
		error "Windows/MSYS Git is not supported on Cygwin"
		error "Make sure the Cygwin git package is installed and is first on the \$PATH"
		exit 1
	fi

	if [ "$OFFLINE" = yes ]; then
		ZSH_CLONE_DIR=$OFFLINE_DIR
		write "${BLUE}Attempting to Clone Oh My Zsh for Offline Cacheing...${RESET}"

	elif [ "$OFFLINE" = no ]; then
		ZSH_CLONE_DIR=$ZSH
		write ${BLUE} "Cloning Oh My Zsh..."${RESET}

	fi

	git clone -c core.eol=lf -c core.autocrlf=false \
		-c fsck.zeroPaddedFilemode=ignore \
		-c fetch.fsck.zeroPaddedFilemode=ignore \
		-c receive.fsck.zeroPaddedFilemode=ignore \
		--depth=1 --quiet --branch "$BRANCH" "$REMOTE" "$ZSH_CLONE_DIR" > /dev/null && write ${BLUE}"Clone Successful"${RESET} || \
		cd $ZSH_CLONE_DIR && git pull --quiet && cd $SELF_PARENT || {
		error "git clone/pull of oh-my-zsh repo failed, trying with offline files."
		OFFLINE=yes
	}
	cd $SELF_PARENT

	if [ "$OFFLINE" = yes ]; then

		if [ ! -d $OFFLINE_DIR ]
		then
			error "Offline directory does not exist at $OFFLINE_DIR"
			write ${YELLOW}"Try running the script with the `--offline` flag while connected to the internet.
		doing so will download the required files."{$RESET}
			exit 1
		fi

		write ${BLUE}"Using Offline Repository at: $OFFLINE_DIR" ${RESET}

		if [ -d $ZSH ]; then
			rm -r $ZSH
		fi
		cp $OFFLINE_DIR $ZSH/ -r || {
			error "Copying Offline Repository to $ZSH dir failed."
			exit 1
		}
	fi

	echo
}

setup_zshrc() {
	# Keep most recent old .zshrc at .zshrc.pre-oh-my-zsh, and older ones
	# with datestamp of installation that moved them aside, so we never actually
	# destroy a user's original zshrc
	write ${BLUE}"Looking for an existing zsh config..." ${RESET}

	# Must use this exact name so uninstall.sh can find it
	OLD_ZSHRC=~/.zshrc.pre-oh-my-zsh
	if [ -f ~/.zshrc ] || [ -h ~/.zshrc ]; then
		# Skip this if the user doesn't want to replace an existing .zshrc
		if [ $KEEP_ZSHRC = yes ]; then
			write "${YELLOW}Found ~/.zshrc.${RESET} ${GREEN}Keeping...${RESET}"
			return
		fi
		if [ -e "$OLD_ZSHRC" ]; then
			OLD_OLD_ZSHRC="${OLD_ZSHRC}-$(date +%Y-%m-%d_%H-%M-%S)"
			if [ -e "$OLD_OLD_ZSHRC" ]; then
				error "$OLD_OLD_ZSHRC exists. Can't back up ${OLD_ZSHRC}"
				error "re-run the installer again in a couple of seconds"
				exit 1
			fi
			mv "$OLD_ZSHRC" "${OLD_OLD_ZSHRC}"

			write "${YELLOW}Found old ~/.zshrc.pre-oh-my-zsh." \
				"${GREEN}Backing up to ${OLD_OLD_ZSHRC}${RESET}"
		fi
		write "${YELLOW}Found ~/.zshrc.${RESET} ${GREEN}Backing up to ${OLD_ZSHRC}${RESET}"
		mv ~/.zshrc "$OLD_ZSHRC"
	fi

	write ${GREEN}"Using the Oh My Zsh template file and adding it to ~/.zshrc."${RESET}

	sed "/^export ZSH=/ c\\
export ZSH=\"$ZSH\"
" "$ZSH/templates/zshrc.zsh-template" > ~/.zshrc-omztemp
	mv -f ~/.zshrc-omztemp ~/.zshrc

	echo
}

setup_shell() {
	# Skip setup if the user wants or stdin is closed (not running interactively).
	if [ $CHSH = no ]; then
		return
	fi

	# If this user's login shell is already "zsh", do not attempt to switch.
	if [ "$(basename "$SHELL")" = "zsh" ]; then
		return
	fi

	# If this platform doesn't provide a "chsh" command, bail out.
	if ! command_exists chsh; then
		cat <<-EOF
			I can't change your shell automatically because this system does not have chsh.
			${BLUE}Please manually change your default shell to zsh${RESET}
		EOF
		return
	fi

	write "${BLUE}Time to change your default shell to zsh:${RESET}"

	# Prompt for user choice on changing the default login shell
	printf "${YELLOW}Do you want to change your default shell to zsh? [Y/n]${RESET} "
	read opt
	case $opt in
		y*|Y*|"") write "Changing the shell..." ;;
		n*|N*) write "Shell change skipped."; return ;;
		*) write "Invalid choice. Shell change skipped."; return ;;
	esac

	# Check if we're running on Termux
	case "$PREFIX" in
		*com.termux*) termux=true; zsh=zsh ;;
		*) termux=false ;;
	esac

	if [ "$termux" != true ]; then
		# Test for the right location of the "shells" file
		if [ -f /etc/shells ]; then
			shells_file=/etc/shells
		elif [ -f /usr/share/defaults/etc/shells ]; then # Solus OS
			shells_file=/usr/share/defaults/etc/shells
		else
			error "could not find /etc/shells file. Change your default shell manually."
			return
		fi

		# Get the path to the right zsh binary
		# 1. Use the most preceding one based on $PATH, then check that it's in the shells file
		# 2. If that fails, get a zsh path from the shells file, then check it actually exists
		if ! zsh=$(which zsh) || ! grep -qx "$zsh" "$shells_file"; then
			if ! zsh=$(grep '^/.*/zsh$' "$shells_file" | tail -1) || [ ! -f "$zsh" ]; then
				error "no zsh binary found or not present in '$shells_file'"
				error "change your default shell manually."
				return
			fi
		fi
	fi

	# We're going to change the default shell, so back up the current one
	if [ -n "$SHELL" ]; then
		write $SHELL > ~/.shell.pre-oh-my-zsh
	else
		grep "^$USER:" /etc/passwd | awk -F: '{print $7}' > ~/.shell.pre-oh-my-zsh
	fi

	# Actually change the default shell to zsh
	if ! chsh -s "$zsh"; then
		error "chsh command unsuccessful. Change your default shell manually."
	else
		export SHELL="$zsh"
		write "${GREEN}Shell successfully changed to '$zsh'.${RESET}"
	fi

	echo
}

main() {
	echo
	
	
	# Run as unattended if stdin is closed
	if [ ! -t 0 ]; then
		RUNZSH=no
		CHSH=no
	fi


	# Parse arguments
	while [ $# -gt 0 ]; do
		case $1 in
			--unattended) RUNZSH=no; CHSH=no ;;
			--skip-chsh) CHSH=no ;;
			--keep-zshrc) KEEP_ZSHRC=yes ;;
			--offline) OFFLINE=yes ;;
			--verbose|-v) VERBOSE=yes ;;
		esac
		shift
	done

	verbose "**START ohmyzsh_install.sh**\n"
	setup_color override

	if [ "$OFFLINE" = yes ]; then
		write ${BOLD}"Set to Offline Mode."${RESET}
	fi

	if ! command_exists zsh; then
		write "${YELLOW}Zsh is not installed.${RESET} Please install zsh first."
		exit 1
	fi

	if [ -d "$ZSH" ] && [ -e "$ZSH/oh-my-zsh.sh" ]; then
		cat <<-EOF
			${YELLOW}You already have Oh My Zsh installed.${RESET}
			You'll need to remove '$ZSH' if you want to reinstall.
		EOF
		exit 1
	fi

	setup_ohmyzsh
	setup_zshrc
	setup_shell

	printf "$GREEN"
	cat <<-'EOF'
		         __                                     __
		  ____  / /_     ____ ___  __  __   ____  _____/ /_
		 / __ \/ __ \   / __ `__ \/ / / /  /_  / / ___/ __ \
		/ /_/ / / / /  / / / / / / /_/ /    / /_(__  ) / / /
		\____/_/ /_/  /_/ /_/ /_/\__, /    /___/____/_/ /_/
		                        /____/                       ....is now installed!


		Before you scream Oh My Zsh! please look over the ~/.zshrc file to select plugins, themes, and options.

		• Follow us on Twitter: https://twitter.com/ohmyzsh
		• Join our Discord server: https://discord.gg/ohmyzsh
		• Get stickers, shirts, coffee mugs and other swag: https://shop.planetargon.com/collections/oh-my-zsh

	EOF
	printf "$RESET"

	if [ $RUNZSH = no ]; then
		write "${YELLOW}Run zsh to try it out.${RESET}\n"
		verbose "**FINISH ohmyzsh_install.sh**\n"
		exit
	fi

	verbose "**FINISH ohmyzsh_install.sh**\n"
	exec zsh -l
}

main "$@"
