#!/bin/bash

set -eux

KERNEL=$(uname)
OH_MY_ZSH_DIR="$HOME/.zsh/oh-my-zsh"
VUNDLE_INSTALL_DIR="$HOME/.vim/bundle/Vundle.vim"
DEFAULT_SYSTEM_PYTHON="3.7.3"

if [ "$KERNEL" == 'Linux' ]; then
    DISTRO=$(lsb_release -sd | tr -d '"' | awk '{print $1;}')
    if [ "$DISTRO" == 'Arch' ]; then
        echo ""
        echo ">> Provisioning for Arch Linux"
        echo ">> Installing essential linux dev tools using pacman"
        echo ""
        sudo pacman -Syu
        sudo pacman -S \
            git \
            ctags \
            pyenv \
            stow \
            docker \
            tree \
            zsh
        yay -Sy \
            githud \
            pyenv-virtualenv \
            yay
    elif [ "$DISTRO" == 'Ubuntu' ]; then
        echo ""
        echo ">> Provisioning for Ubuntu"
        echo ">> Installing essential linux dev tools using apt-get\n"
        echo ""
        sudo apt-get update
        sudo apt-get -y install \
            build-essential \
            ctags \
            curl \
            elinks \
            git \
            git-core \
            htop \
            sl \
            stow \
            tree \
            tree \
            vim-nox \
            zsh
        git -C "$HOME/.pyenv" pull || git clone https://github.com/pyenv/pyenv.git "$HOME/.pyenv"
        git -C "$HOME/.pyenv/plugins/pyenv-virtualenv" pull || git clone https://github.com/pyenv/pyenv-virtualenv.git "$HOME/.pyenv/plugins/pyenv-virtualenvwrapper"
    else
        echo "Never heard of that Pokemon."
        exit 1
    fi
elif [ "$KERNEL" == 'Darwin' ]; then
    echo ""
    echo ">> Installing brew and other mac shenanigans"
    echo ""
    hash brew 2>/dev/null || /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew install \
        archey \
        awscli \
        bash \
        byobu \
        coreutils \
        elinks \
        gcc \
        git-lfs \
        gnu-getopt \
        jrnl \
        nmap \
        postgresql \
        pyenv \
        pyenv-virtualenv \
        python \
        readline \
        reattach-to-user-namespace \
        scala \
        sl \
        stow \
        tree \
        vim \
        wget || echo "Skipping brew install"
    brew tap caskroom/versions
    brew cask install caffeine
    brew tap gbataille/homebrew-gba
fi

echo ""
echo ">> Installing Python $DEFAULT_SYSTEM_PYTHON as default"
echo ""
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
pyenv install -f $DEFAULT_SYSTEM_PYTHON
pyenv global $DEFAULT_SYSTEM_PYTHON
pip install pygments

echo "Installing/Upgrading  ZSH"
# Install oh-my-zsh or update if already installed
if [ ! -d $OH_MY_ZSH_DIR ]; then
    git clone https://github.com/robbyrussell/oh-my-zsh.git $OH_MY_ZSH_DIR
elif [ -d $OH_MY_ZSH_DIR -a -d $OH_MY_ZSH_DIR/.git ]; then
    git --git-dir=$OH_MY_ZSH_DIR/.git pull origin master
fi

# Install Vundle (updates are managed by `BundleUpdate`
if [ ! -d "$VUNDLE_INSTALL_DIR" ]; then
    git clone https://github.com/VundleVim/Vundle.vim.git $VUNDLE_INSTALL_DIR
fi

# Set up all symlinks
stow -t $HOME alacritty
stow -t $HOME docker
stow -t $HOME git
stow -t $HOME tmux
stow -t $HOME vim
stow -t $HOME zsh
stow -t $HOME scripts

# Done!
sudo usermod -s /bin/zsh "$USER"
echo "All done! Log out of all open sessions to install new env!"
