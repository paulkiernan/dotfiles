#!/bin/bash

set -eux

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

UNAME_STR=$(uname)
if [ "$UNAME_STR" == 'Linux' ]; then
    echo ""
    echo ">> Installing essential dev tools using apt-get"
    echo ""
    sudo apt-get update
    sudo apt-get -y install sl curl bash-completion build-essential zsh vim \
        byobu elinks tree ipython bpython python-setuptools python-dev      \
        python-pip git-core ctags zsh tree
elif [ "$UNAME_STR" == 'Darwin' ]; then
    # Install brew, the package manager for drunks
    hash brew 2>/dev/null || ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
    brew install python sl vim byobu tree wget
    brew install michaeldfallen/formula/git-radar
    brew install archey
    pip install ipython virtualenvwrapper Pygments
fi

rm -f "$HOME/.gitconfig"
lnif -s "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"

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
mkdir -p ~/.byobu
lnif "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
lnif "$DOTFILES_DIR/zsh" "$OH_MY_ZSH_DIR/custom"
lnif "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
lnif "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"
lnif "$DOTFILES_DIR/.tmux.conf" "$HOME/.byobu/.tmux.conf"
lnif "$DOTFILES_DIR/.tmux.conf" "$HOME/.byoburc.tmux"
lnif "$DOTFILES_DIR/.vimrc" "$HOME/.vimrc"
lnif "$DOTFILES_DIR/.vimrc.bundles" "$HOME/.vimrc.bundles"
lnif "$DOTFILES_DIR/.dockerrc" "$HOME/.dockerrc"

# Download vundle to bootstrap vimconfig
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/vundle

# Done!
sudo chsh -s /bin/zsh
echo "All done! Log out of all open sessions to install new env!"
