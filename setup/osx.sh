echo ""
echo ">> Installing brew and other mac shenanigans"
echo ""
hash brew 2>/dev/null || /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
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
    vim \
    wget || echo "Skipping brew install"

# Alternate installs
brew tap homebrew/cask-versions
brew cask install caffeine

# Install git-hud
brew tap gbataille/homebrew-gba
