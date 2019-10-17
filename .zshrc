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
)

source $ZSH/oh-my-zsh.sh

BROWSER=/usr/bin/chromium
EDITOR=/usr/bin/vim
# export MANPATH="/usr/local/man:$MANPATH"
# export LANG=en_US.UTF-8
function mimeopen () {nohup mimeopen "$@" &>/dev/null & disown}
function libreoffice () {nohup libreoffice "$@" &>/dev/null & disown}
function firefox () {nohup firefox "$@" &>/dev/null & disown}
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
alias calcurse='calcurse -D ~/.config/calcurse'
cowtune 2>/dev/null
# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
#export PATH="$PATH:$HOME/.rvm/bin"
