# dotfiles

An amazing vim config, a mediocre zsh config, and (for those with no fear) emojis in your terminal.

Also my script for quickly updating/installing my dotfiles on many machines.

# Dependencies
## Ubuntu
```bash
sudo apt update
sudo apt install git vim fonts-powerline exuberant-ctags zsh gdb curl openssh-server -y
```

## Usage:

* Combined Using `setup.sh`

    `git clone` this repository, then:

    ```bash
    git clone --recurse-submodules -j8 https://github.com/rbaas293/dotfiles.git
    cd dotfiles
    ./setup.sh [--offline] [--verbose]
    ```

    An optional _offline mode_ is included which provides the functionality to run the script on an
    _online_ computer then transfer it to an _offline_ computer. This method assumes
    there is an **apt/pacman mirror** on the _offline_ network.

    Simply pass the `--offline` switch to
    `setup.py` while _online_ to download the required repositories, then transfer this repo to the
    _offline_ machine and run again.

* `zsh`

    ```bash
    sudo ./dotfilesInstallScripts/zsh_deps.sh
    ./dotfilesInstallScripts/zshsetup.sh
    python3 update_dotfiles.py --install -f .zshrc
    sudo chsh -s /usr/bin/zsh
    ```

* `vim`

    ```bash
    sudo ./dotfilesInstallScripts/vim_deps.sh
    ./update_dotfiles.py --install -f .vimrc
    vim
    ```

### `update_dotfiles.py`

```bash
usage: update_dotfiles.py [-h] [--list-files] [--list-repos] [--install]
                          [-f FILES [FILES ...]] [--commit COMMIT] [--verbose]

This is a quick script to update dotfiles quickly. Settings are located in
~/.config/my-dotfiles-settings

optional arguments:
  -h, --help            show this help message and exit
  --list-files          Lists files that will be updated
  --list-repos          List the repo locations that will be updated
  --install             Install files to current user's config
  -f FILES [FILES ...], --files FILES [FILES ...]
                        Specific files that you would like to update
  --commit COMMIT       Commit message for git repo
  --verbose             verbose mode
```
