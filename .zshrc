export ZSH=~/.oh-my-zsh

# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
#ZSH_THEME="robbyrussell"
ZSH_THEME="bira"
#ZSH_THEME="agnostar"

# ZSH_THEME_RANDOM_CANDIDATES=( "bira" "agnoster" )
# CASE_SENSITIVE="true"
# HYPHEN_INSENSITIVE="true"
# DISABLE_AUTO_UPDATE="true"
# export UPDATE_ZSH_DAYS=13
# DISABLE_LS_COLORS="true"
# DISABLE_AUTO_TITLE="true"
# ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"
# DISABLE_UNTRACKED_FILES_DIRTY="true"
DISABLE_UPDATE_PROMPT=true
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"
# ZSH_CUSTOM=/path/to/new-custom-folder
plugins=(
  git
  colorize
  colored-man-pages
  cp
  tmux
  tmuxinator
  repo
  pip
  vundle
  battery
  command-not-found
  zsh-syntax-highlighting
  zsh-autosuggestions
  nmap
  python
  rsync
  rand-quote
  systemd
  man
  screen
  pyenv
)

source $ZSH/oh-my-zsh.sh

BROWSER=/usr/bin/chromium
EDITOR=/usr/bin/vim
# export MANPATH="/usr/local/man:$MANPATH"
# export LANG=en_US.UTF-8
#

# Auto update path for completion
# zstyle ':completion:*' rehash true
function findpacbin () {pacman -Ql "$@" | cut -d ' ' -f2- | grep -v "/$" | grep --color=never -P "/(bin|sbin)/"}

function b64d () {base64 -d <(echo "$@")}
function mimeopen () {nohup mimeopen "$@" &>/dev/null & disown}
function libreoffice () {nohup libreoffice "$@" &>/dev/null & disown}
function firefox () {nohup firefox "$@" &>/dev/null & disown}
function ida () {nohup ida "$@" &>/dev/null & disown}
function newpy () {echo "#!/usr/bin/python3" > "$@" && chmod +x "$@"}
function newpyvenv () {
	if [ ! -d .venv ]; then
		pyenv exec python -m venv .venv
	fi
}
# using some functions from the archwiki
# https://wiki.archlinux.org/index.php/Bash/Functions
function extract () {
    local c e i

    (($#)) || return

    for i; do
        c=''
        e=1

        if [[ ! -r $i ]]; then
            echo "$0: file is unreadable: \`$i'" >&2
            continue
        fi

        case $i in
            *.t*(gz|lz|xz|b*(2|z?(2))|a*(z|r?(.*(Z|bz?(2)|gz|lzma|xz)))))
                   c=(bsdtar xvf);;
            *.7z)  c=(7z x);;
            *.Z)   c=(uncompress);;
            *.bz2) c=(bunzip2);;
            *.exe) c=(cabextract);;
            *.gz)  c=(gunzip);;
            *.rar) c=(unrar x);;
            *.xz)  c=(unxz);;
            *.zip) c=(unzip);;
            *)     echo "$0: unrecognized file extension: \`$i'" >&2
                   continue;;
        esac

        command "${c[@]}" "$i"
        ((e = e || $?))
    done
    return "$e"
}
function todo () {
    if [[ ! -f $HOME/.todo ]]; then
        touch "$HOME/.todo"
    fi

    if ! (($#)); then
        cat "$HOME/.todo"
    elif [[ "$1" == "-l" ]]; then
        nl -b a "$HOME/.todo"
    elif [[ "$1" == "-c" ]]; then
        > $HOME/.todo
    elif [[ "$1" == "-r" ]]; then
        nl -b a "$HOME/.todo"
        eval printf %.0s- '{1..'"${COLUMNS:-$(tput cols)}"\}
        read "number?Type a number to remove: "
        sed -i ${number}d $HOME/.todo "$HOME/.todo"
    else
        printf "%s\n" "$*" >> "$HOME/.todo"
    fi
}

function getmaketargets () {
	make -qp | awk -F':' '/^[a-zA-Z0-9][^$#\/\t=]*:([^=]|$)/ {split($1,A,/ /);for(i in A)print A[i]}' | sort -u
}

function getzshfunctionnames () {
	# should be obvious, but only works for zsh
	functions | grep -Po --color=never '^[a-zA-Z]+(?= \(\))'
}


if [ -d "/opt/ghidra/support" ];then
	export PATH="/opt/ghidra/support:$PATH"
fi


alias ls='ls --color=auto'
alias ll='ls -Ahl --color=auto --group-directories-first'
alias la='cat ~/.zshrc | grep -P -o "(?<=^alias\ ).+"'
alias ls='ls --color=auto'
alias eb='vim ~/.bashrc'
alias pacrepo='sudo reflector -l 20 -f 10 --save /etc/pacman.d/mirrorlist'
alias pacu='sudo pacman -Syu --noconfirm'
alias se='ls /usr/bin /bin /sbin | sort | uniq | grep -i'
alias calc='gnome-calculator &>/dev/null & disown'
alias steam='steam &>/dev/null & disown'
alias disks='ls -Ahl --color=auto /dev/disks/by-label/'
alias ev='vim ~/.vimrc'
alias show-tree='systemd-cgls / pstree'
alias ez='vim ~/.zshrc'
alias pwsh='env TERM=xterm pwsh'
alias rake='noglob rake'
alias meow='lolcat'
command -v fortune >/dev/null && command -v cowthink >/dev/null && alias cowtune='fortune -e | cowthink -n'
alias inet4='ip addr | grep -P "inet[^6]"'
alias list-bindsyms='cat ~/.config/i3/config | grep -P "^bindsym" --color=never'
alias ei3='vim ~/.config/i3/config'
alias quickswap='mkdir -p /mnt/ram; mount -t tmpfs tmpfs /mnt/ram -o size=4096'
alias ccat='highlight'
alias ssh='TERM=linux ssh'
alias sshpass='TERM=linux sshpass'
alias ansible-vault="EDITOR=$EDITOR ansible-vault"
alias gb='git branch -a | cat -'
alias gbv='git branch -vv'
alias calcurse='calcurse -D ~/.config/calcurse'
alias glggv='git log --graph --full-history --all --color --pretty=format:"%x1b[31m%h%x09%x1b[32m%d%x1b[0m%x20%s"'
alias yeet='yay -Rsn'
alias reload='source ~/.zshrc'
cowtune 2>/dev/null
# command -v virtualenvwrapper.sh >/dev/null && source $(whereis virtualenvwrapper.sh | cut -f2- -d ' ')'
# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
#export PATH="$PATH:$HOME/.rvm/bin"
