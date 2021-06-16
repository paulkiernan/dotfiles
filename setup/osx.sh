echo ""
echo ">> Installing brew and other mac shenanigans"
echo ""
hash brew 2>/dev/null || bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install \
    archey \
    awscli \
    bash \
    coreutils \
    git-lfs \
    gnu-getopt \
    jrnl \
    nmap \
    pyenv \
    pyenv-virtualenv \
    reattach-to-user-namespace \
    sl \
    stow \
    tree \
    tmux \
    vim \
    wget || echo "Skipping brew install"

# Application installs
brew tap homebrew/cask-versions
brew install --cask \
    caffeine \
    docker \
    dropbox \
    pritunl \
    spotify

# Install git-hud
brew tap gbataille/homebrew-gba
