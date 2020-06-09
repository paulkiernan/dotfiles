echo ""
echo ">> Provisioning for Ubuntu"
echo ">> Installing essential linux dev tools using apt-get\n"
echo ""
sudo apt-get update
sudo apt-get -y install \
    build-essential \
    ctags \
    curl \
    elinks \
    git \
    git-core \
    htop \
    sl \
    stow \
    tree \
    tree \
    vim-nox \
    zsh
