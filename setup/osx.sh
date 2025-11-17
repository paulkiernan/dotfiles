echo ""
echo ">> Installing brew and other mac shenanigans"
echo ""
hash brew 2>/dev/null || bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

export PATH=$PATH:/opt/homebrew/bin

# Install brew formulas individually
FORMULAS=(
    archey4
    bash
    coreutils
    direnv
    gnu-getopt
    htop
    jq
    nmap
    reattach-to-user-namespace
    sl
    stow
    tmux
    tree
    vim
    wget
)

echo ""
echo ">> Installing brew formulas"
for formula in "${FORMULAS[@]}"; do
    if brew list "$formula" &>/dev/null; then
        echo "✓ $formula already installed"
    else
        echo "Installing $formula..."
        brew install "$formula" || echo "✗ Failed to install $formula"
    fi
done

# Install cask applications individually
CASKS=(
    caffeine
    discord
    docker
    dropbox
    ghostty
    obsidian
    slack
    spotify
    sublime-text
)

echo ""
echo ">> Installing cask applications"
for cask in "${CASKS[@]}"; do
    if brew list --cask "$cask" &>/dev/null; then
        echo "✓ $cask already installed"
    else
        echo "Installing $cask..."
        brew install --cask "$cask" || echo "✗ Failed to install $cask"
    fi
done
