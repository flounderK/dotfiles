# dotfiles

An amazing vim config, a mediocre zsh config, and (for those with no fear) emojis in your terminal.

Also my script for quickly updating/installing my dotfiles on many machines.

Usage:

for zsh:
```bash
sudo ./dotfilesInstallScripts/zsh_deps.sh
./dotfilesInstallScripts/zshsetup.sh
python3 update_dotfiles.py --install -f .zshrc
sudo chsh -s /usr/bin/zsh
```

for vim:
```bash
sudo ./dotfilesInstallScripts/vim_deps.sh
./update_dotfiles.py --install -f .vimrc
vim
```
