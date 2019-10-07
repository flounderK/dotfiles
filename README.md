# dotfiles

An amazing vim config, a mediocre zsh config, and (for those with no fear) emojis in your terminal.

Also my script for quickly updating/installing my dotfiles on many machines.

Usage:

for zsh:
`sudo ./dotfilesInstallScripts/zsh_deps.sh`
`./dotfilesInstallScripts/zshsetup.sh`
`python3 update_dotfiles.py --install -f .zshrc`
`sudo chsh -s /usr/bin/zsh`

for vim:
`sudo ./dotfilesInstallScripts/vim_deps.sh`
`python3 update_dotfiles.py --install -f .vimrc`
`./dotfilesInstallScripts/vimsetup.sh`

