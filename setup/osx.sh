echo ""
echo ">> Installing brew and other mac shenanigans"
echo ""
hash brew 2>/dev/null || bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install \
    archey \
    asdf \
    direnv \
    awscli \
    bash \
    coreutils \
    git-lfs \
    gnu-getopt \
    jq \
    jrnl \
    nmap \
    pyenv \
    pyenv-virtualenv \
    reattach-to-user-namespace \
    sl \
    stow \
    tmux \
    tree \
    vim \
    wget || echo "Skipping brew install"

# Application installs
brew tap homebrew/cask-versions
brew install --cask \
    caffeine \
    docker \
    dropbox \
    iterm2 \
    pritunl \
    spotify \
    sublime-text

# Install git-hud
brew tap gbataille/homebrew-gba
