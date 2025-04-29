echo ""
echo ">> Installing brew and other mac shenanigans"
echo ""
hash brew 2>/dev/null || bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

export PATH=$PATH:/opt/homebrew/bin

brew install \
    archey4 \
    asdf \
    bash \
    coreutils \
    direnv \
    gnu-getopt \
    htop \
    jq \
    nmap \
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
    ghostty \
    obsidian \
    slack \
    spotify \
    sublime-text
