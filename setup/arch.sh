echo ""
echo ">> Provisioning for Arch Linux"
echo ">> Installing essential linux dev tools using pacman"
echo ""
sudo pacman -Syu
sudo pacman -Sy --noconfirm \
    base-devel \
    ctags \
    docker \
    git \
    htop \
    pyenv \
    stow \
    tmux \
    tree \
    xsel \
    zsh

echo ">> Installing AUR Helper tools" 
echo ""
cd /opt
sudo rm -rf yay
sudo git clone --depth 1 https://aur.archlinux.org/yay.git
sudo chown $USER:$USER yay
cd yay
makepkg -si --noconfirm
yay -Sy --noconfirm \
    archey3 \
    githud \
    pyenv-virtualenv \
    yay
sudo rm -rf /opt/yay
