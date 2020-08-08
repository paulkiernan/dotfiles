echo ""
echo ">> Installing brew and other mac shenanigans"
echo ""
hash brew 2>/dev/null || /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew install \
    archey \
    awscli \
    bash \
    byobu \
    coreutils \
    elinks \
    gcc \
    git-lfs \
    gnu-getopt \
    jrnl \
    nmap \
    pyenv \
    pyenv-virtualenv \
    python \
    readline \
    reattach-to-user-namespace \
    scala \
    sl \
    stow \
    tree \
    vim \
    wget || echo "Skipping brew install"
brew tap caskroom/versions
brew cask install caffeine
brew tap gbataille/homebrew-gba
