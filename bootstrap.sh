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
echo ""
echo ">> Setting up dotfile symlinks with stow"
echo ""

STOW_PACKAGES=(docker git linux osx scripts tmux vim zsh)

for package in "${STOW_PACKAGES[@]}"; do
    if [ -d "$package" ]; then
        echo "Stowing $package..."
        stow -t "$HOME" "$package" 2>/dev/null || stow -R -t "$HOME" "$package" || echo "✗ Failed to stow $package"
    else
        echo "✗ Directory $package not found, skipping"
    fi
done

# Ghostty config
mkdir -p "$HOME/.config/ghostty"
if [ -d "ghostty" ]; then
    echo "Stowing ghostty config..."
    stow -t "$HOME/.config/ghostty" ghostty 2>/dev/null || stow -R -t "$HOME/.config/ghostty" ghostty || echo "✗ Failed to stow ghostty"
else
    echo "✗ Directory ghostty not found, skipping"
fi

echo ""
echo ">> Installing/Upgrading oh-my-zsh"
# Install oh-my-zsh or update if already installed
if [ ! -d "$OH_MY_ZSH_DIR" ]; then
    echo "Installing oh-my-zsh to $OH_MY_ZSH_DIR..."
    git clone https://github.com/robbyrussell/oh-my-zsh.git "$OH_MY_ZSH_DIR" || echo "✗ Failed to install oh-my-zsh"
elif [ -d "$OH_MY_ZSH_DIR/.git" ]; then
    echo "Updating oh-my-zsh..."
    git -C "$OH_MY_ZSH_DIR" pull origin master || echo "✗ Failed to update oh-my-zsh"
else
    echo "✓ oh-my-zsh directory exists (not a git repo)"
fi

echo "Installing/Upgrading  Powerlevel10k"
mkdir -p $HOME/.zsh/zsh_custom/themes
if [ ! -d $POWERLEVEL10K_DIR ]; then
    git clone https://github.com/romkatv/powerlevel10k.git $POWERLEVEL10K_DIR
elif [ -d $POWERLEVEL10K_DIR -a -d $POWERLEVEL10K_DIR/.git ]; then
    git --git-dir=$POWERLEVEL10K_DIR/.git pull origin master
fi

echo ""
echo ">> Installing Vundle for vim"
# Install Vundle (updates are managed by `BundleUpdate`)
if [ ! -d "$VUNDLE_DIR" ]; then
    echo "Installing Vundle to $VUNDLE_DIR..."
    mkdir -p "$(dirname "$VUNDLE_DIR")"
    git clone https://github.com/VundleVim/Vundle.vim.git "$VUNDLE_DIR" || echo "✗ Failed to install Vundle"
else
    echo "✓ Vundle already installed"
fi

echo ""
echo "=========================================="
echo "✓ Bootstrap complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "  1. Log out and log back in to activate zsh"
echo "  2. Run 'vim +PluginInstall +qall' to install vim plugins"
echo ""
