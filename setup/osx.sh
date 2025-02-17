echo ""
echo ">> Installing brew and other mac shenanigans"
echo ""
hash brew 2>/dev/null || bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

export PATH=$PATH:/opt/homebrew/bin

brew install \
    archey4 \
    bash \
    coreutils \
    direnv \
    git-lfs \
    gnu-getopt \
    htop \
    jq \
    nmap \
    pyenv \
    reattach-to-user-namespace \
    sl \
    stow \
    tmux \
    tree \
    vim \
    wget || echo "Skipping brew install"

# Application installs
brew install --cask \
    caffeine \
    discord \
    docker \
    dropbox \
    iterm2 \
    obsidian \
    slack \
    spotify \
    sublime-text

# Install git-hud
brew tap gbataille/homebrew-gba
brew install githud
