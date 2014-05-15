#!/bin/bash

set -eu

# Definitions
DOTFILES_DIR=$HOME/.dotfiles
OH_MY_ZSH_DIR=$DOTFILES_DIR/oh-my-zsh
Z_COMPLETION_DIR=$DOTFILES_DIR/z

lnif() {
    if [ ! -e $2 ] ; then
        ln -s $1 $2
    fi
    if [ -L $2 ] ; then
        ln -sf $1 $2
    fi
}

UNAME_STR=`uname`
if [ "$UNAME_STR" == 'Linux' ]; then
    # Keep EC2 connections from periodically hanging up
    KEEPALIVE="KeepAlive yes"
    ALIVETIMEOUT="ClientAliveInterval 60"
    if ! sudo grep -Fxq "$KEEPALIVE" /etc/ssh/sshd_config; then
        echo "$KEEPALIVE" | sudo tee -a /etc/ssh/sshd_config
    filename
    if ! sudo grep -Fxq "$ALIVETIMEOUT" /etc/ssh/sshd_config; then
        echo "$ALIVETIMEOUT" | sudo tee -a /etc/ssh/sshd_config
    fi

    echo ""
    echo ">> Installing essential dev tools using apt-get"
    echo ""
    sudo apt-get update
    sudo apt-get -y install sl curl bash-completion build-essential zsh vim \
        byobu elinks tree ipython bpython python-setuptools python-dev      \
        python-pip git-core ctags zsh tree
elif [ "$UNAME_STR" == 'Darwin' ]; then
    # Install brew, the package manager for drunks
    ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)" || true


fi

rm -f "$HOME/.gitconfig"
ln -s "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"

echo ""
echo ">> Creating the local lib directory for dotfiles"
echo ""
if [ ! -d $DOTFILES_DIR ]; then
    # Clone into dotfiles for the first time
    git clone https://github.com/paulkiernan/dotfiles $DOTFILES_DIR
elif [ -d $DOTFILES_DIR -a -d $DOTFILES_DIR/.git ]; then
    cd $DOTFILES_DIR
    git pull origin master
    cd $HOME
fi;

# Install ZSH stuff
echo "Installing ZSH"
sudo chsh -s $(which zsh) $USER
if [ ! -d $OH_MY_ZSH_DIR ]; then
    git clone git://github.com/robbyrussell/oh-my-zsh.git $OH_MY_ZSH_DIR
elif [ -d $OH_MY_ZSH_DIR -a -d $OH_MY_ZSH_DIR/.git ]; then
    cd $OH_MY_ZSH_DIR 
    git pull origin master
    cd $HOME
fi
if [ ! -d $Z_COMPLETION_DIR ]; then
    git clone git://github.com/sjl/z-zsh $Z_COMPLETION_DIR
elif [ -d $Z_COMPLETION_DIR -a -d $Z_COMPLETION_DIR/.git ]; then
    cd $Z_COMPLETION_DIR
    git pull origin master
    cd $HOME
fi

# Set up symlinks!
lnif "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
lnif "$DOTFILES_DIR/zsh" "$OH_MY_ZSH_DIR/custom"
lnif "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
lnif "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"
lnif "$DOTFILES_DIR/.tmux.conf" "$HOME/.byoburc.tmux"
lnif "$DOTFILES_DIR/.vimrc.local" "$HOME/.vimrc.local"
lnif "$DOTFILES_DIR/.vimrc.before.local" "$HOME/.vimrc.before.local"
lnif "$DOTFILES_DIR/.vimrc.bundles.local" "$HOME/.vimrc.bundles.local"

# Install Steve Francia's awesome vim config
curl --insecure http://j.mp/spf13-vim3 -L -o - | sh || true

# Done!
echo "All done! Log out of all open sessions to install new env!"
