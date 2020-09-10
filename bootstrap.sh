#!/bin/bash

set -eux

KERNEL=$(uname)
DEFAULT_PYTHON_VERSIONS=("3.8.5")

ASDF_DIR="$HOME/.asdf"
ASDF_VERSION="v0.7.8"
OH_MY_ZSH_DIR="$HOME/.zsh/oh-my-zsh"
VUNDLE_DIR="$HOME/.vim/bundle/Vundle.vim"

if [ "$KERNEL" == 'Linux' ]; then
    DISTRO=$(lsb_release -sd | tr -d '"' | awk '{print $1;}')
    if [ "$DISTRO" == 'Arch' ]; then
        source setup/arch.sh
    elif [ "$DISTRO" == 'Ubuntu' ]; then
        source setup/ubuntu.sh
    else
        echo "Never heard of that Pokemon."
        exit 1
    fi
elif [ "$KERNEL" == 'Darwin' ]; then
    source setup/osx.sh
fi

echo ""
echo ">> Installing Python version(s) ${DEFAULT_PYTHON_VERSIONS} as default"
if [ ! -d $ASDF_DIR ]; then
    git clone https://github.com/asdf-vm/asdf.git "$ASDF_DIR" --branch "$ASDF_VERSION"
elif [ -d $ASDF_DIR -a -d $ASDF_DIR/.git ]; then
    git --git-dir=$ASDF_DIR/.git checkout origin/master -B "$ASDF_VERSION"
fi
for python_version in "${DEFAULT_PYTHON_VERSIONS[@]}"; do
    if [ !$(pyenv versions | grep "$python_version") ]; then
        pyenv install "$python_version"
    fi
done
pip install --user pygments

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

# Set up all symlinks
stow -t $HOME alacritty
stow -t $HOME docker
stow -t $HOME git
stow -t $HOME tmux
stow -t $HOME vim
stow -t $HOME zsh
stow -t $HOME scripts
stow -t $HOME linux
stow -t $HOME osx

# Done!
sudo usermod -s /bin/zsh "$USER"
echo "All done! Log out of all open sessions to install new env!"
