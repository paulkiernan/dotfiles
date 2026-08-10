#!/bin/bash
set -eux

KERNEL=$(uname)

OH_MY_ZSH_DIR="$HOME/.zsh/oh-my-zsh"
POWERLEVEL10K_DIR="$HOME/.zsh/zsh_custom/themes/powerlevel10k"
VUNDLE_DIR="$HOME/.vim/bundle/Vundle.vim"

if [ "$KERNEL" == 'Linux' ]; then
    DISTRO=$(lsb_release -sd | tr -d '"' | awk '{print $1;}')
    if [ "$DISTRO" == 'Arch' ] || [ "$DISTRO" == 'Manjaro' ]; then
        source setup/arch.sh
    elif [ "$DISTRO" == 'Ubuntu' ] || [ "$DISTRO" == 'Debian' ] || [ "$DISTRO" == 'Parrot' ]; then
        source setup/ubuntu.sh
    else
        echo "Never heard of that Pokemon."
        exit 1
    fi
    sudo usermod -s /bin/zsh "$USER"
elif [ "$KERNEL" == 'Darwin' ]; then
    source setup/osx.sh
fi

# ASDF + toolchains -----------------------------------------------------------
ASDF_DIR="$HOME/.asdf"

# Known-stable toolchain versions (explicit pins; `latest` can resolve to
# free-threaded/experimental builds that break installs).
# Python is intentionally NOT installed here: asdf builds it from source,
# which needs sudo + system build deps (libssl-dev etc.) on every machine.
# Node and rust ship precompiled binaries, so they install without compilation.
ASDF_NODEJS_VERSION="24.19.0"
ASDF_RUST_VERSION="1.97.1"

echo "Installing/Upgrading ASDF"
if ! command -v asdf >/dev/null 2>&1; then
    if [ ! -d "$ASDF_DIR" ]; then
        git clone https://github.com/asdf-vm/asdf.git "$ASDF_DIR"
    elif [ -d "$ASDF_DIR/.git" ]; then
        git -C "$ASDF_DIR" pull
    fi
    # Make the asdf command available for the rest of this script
    export PATH="$ASDF_DIR/bin:$PATH"
    [ -s "$ASDF_DIR/asdf.sh" ] && . "$ASDF_DIR/asdf.sh"
fi

if ! command -v asdf >/dev/null 2>&1; then
    echo "ERROR: asdf not found on PATH after install" >&2
    exit 1
fi

echo "Installing asdf plugins (nodejs, rust)"
for plugin in nodejs rust; do
    if ! asdf plugin list | grep -qx "$plugin"; then
        asdf plugin add "$plugin"
    else
        echo "  plugin $plugin already present"
    fi
done

echo "Installing known-stable toolchains via asdf"
asdf install nodejs "$ASDF_NODEJS_VERSION"
asdf install rust "$ASDF_RUST_VERSION"

# `asdf set -u` is the modern form; older asdf uses `asdf global`.
if asdf set --help >/dev/null 2>&1; then
    ASDF_SET="asdf set -u"
else
    ASDF_SET="asdf global"
fi
echo "Setting global tool versions"
$ASDF_SET nodejs "$ASDF_NODEJS_VERSION"
$ASDF_SET rust "$ASDF_RUST_VERSION"

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
    git clone https://github.com/ohmyzsh/ohmyzsh.git $OH_MY_ZSH_DIR
elif [ -d $OH_MY_ZSH_DIR -a -d $OH_MY_ZSH_DIR/.git ]; then
    git --git-dir=$OH_MY_ZSH_DIR/.git pull origin master
fi

echo "Installing/Upgrading  Powerlevel10k"
mkdir -p $HOME/.zsh/zsh_custom/themes
if [ ! -d $POWERLEVEL10K_DIR ]; then
    git clone https://github.com/romkatv/powerlevel10k.git $POWERLEVEL10K_DIR
elif [ -d $POWERLEVEL10K_DIR -a -d $POWERLEVEL10K_DIR/.git ]; then
    git --git-dir=$POWERLEVEL10K_DIR/.git pull origin master
fi

# Install Vundle (updates are managed by `BundleUpdate`
if [ ! -d "$VUNDLE_DIR" ]; then
    git clone https://github.com/VundleVim/Vundle.vim.git $VUNDLE_DIR
fi

echo "All done! Log out of all open sessions to install new env!"
