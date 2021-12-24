# dotfiles

An amazing vim config, a mediocre zsh config, and (for those with no fear) emojis in your terminal.

Also my script for quickly updating/installing my dotfiles on many machines.

Eventually much of this might be merged with the ctf environment setup scripts because there is so much overlap [https://github.com/flounderK/ctf-environment](https://github.com/flounderK/ctf-environment)

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
