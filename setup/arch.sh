echo ""
echo ">> Provisioning for Arch Linux"
echo ">> Installing essential linux dev tools using pacman"
echo ""
sudo pacman -Syu
sudo pacman -Sy \
    ctags \
    docker \
    git \
    stow \
    tree \
    xsel \
    zsh
yay -Sy \
    githud \
    yay
