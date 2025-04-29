#!/bin/bash

set -eux

KERNEL=$(uname)

OH_MY_ZSH_DIR="$HOME/.zsh/oh-my-zsh"
VUNDLE_DIR="$HOME/.vim/bundle/Vundle.vim"

if [ "$KERNEL" == 'Linux' ]; then
    DISTRO=$(lsb_release -sd | tr -d '"' | awk '{print $1;}')
    if [ "$DISTRO" == 'Arch' ] || [ "$DISTRO" == 'Manjaro' ]; then
        source setup/arch.sh
    elif [ "$DISTRO" == 'Ubuntu' ]; then
        source setup/ubuntu.sh
    else
        echo "Never heard of that Pokemon."
        exit 1
    fi
    sudo usermod -s /bin/zsh "$USER"
elif [ "$KERNEL" == 'Darwin' ]; then
    source setup/osx.sh
fi

# Set up all dotfile symlinks -------------------------------------------------
stow -t $HOME docker
stow -t $HOME git
stow -t $HOME linux
stow -t $HOME osx
stow -t $HOME scripts
stow -t $HOME tmux
stow -t $HOME vim
stow -t $HOME zsh

mkdir -p $HOME/.config
mkdir -p $HOME/.config/ghostty
stow -t $HOME/.config/ghostty ghostty

echo "Installing/Upgrading  ZSH"
# Install oh-my-zsh or update if already installed
if [ ! -d $OH_MY_ZSH_DIR ]; then
    git clone https://github.com/robbyrussell/oh-my-zsh.git $OH_MY_ZSH_DIR
elif [ -d $OH_MY_ZSH_DIR -a -d $OH_MY_ZSH_DIR/.git ]; then
    git --git-dir=$OH_MY_ZSH_DIR/.git pull origin master
fi

# Install Vundle (updates are managed by `BundleUpdate`
if [ ! -d "$VUNDLE_DIR" ]; then
    git clone https://github.com/VundleVim/Vundle.vim.git $VUNDLE_DIR
fi

echo "All done! Log out of all open sessions to install new env!"
