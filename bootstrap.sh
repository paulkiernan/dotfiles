# Use this file to (re)build a familiar command line env
# run "wget --no-check-certificate https://github.com/paulkiernan/dotfiles/raw/master/bootstrap.sh -O - | sh"

# Don't forget the SSH keys.
# Need to sudo to sucessfully apt-get

echo "Creating the local lib directory for dotfiles"
mkdir ~/.dotfiles/

# Install essential dev tools
sudo apt-get -y install sl curl bash-completion build-essential zsh vim byobu \
    elinks tree
# Install python tools
sudo apt-get -y install ipython bpython python-setuptools python-dev python-pip

# Install git stuff
sudo apt-get -y install git-core
sudo apt-get -y install git-flow
rm "$HOME/.gitconfig"
ln -s "$HOME/.dotfiles/.gitconfig" "$HOME/.gitconfig"

# Install these dotfiles locally
git clone https://github.com/paulkiernan/dotfiles $HOME/.dotfiles

# Install ZSH stuff
echo "Installing ZSH"
chsh -s /bin/zsh
git clone git://github.com/robbyrussell/oh-my-zsh.git $HOME/.dotfiles/oh-my-zsh
git clone git://github.com/sjl/z-zsh $HOME/.dotfiles/z
rm ~/.zshrc
ln -s "$HOME/.dotfiles/.zshrc" "$HOME/.zshrc"
ln -s "$HOME/.dotfiles/zsh" "$HOME/.dotfiles/oh-my-zsh/custom"

# Install other config settings
rm "$HOME/.gitconfig"
ln -s "$HOME/.dotfiles/.gitconfig" "$HOME/.gitconfig"
ln -s "$HOME/.dotfiles/.tmux.conf" "$HOME/.tmux.conf"
ln -s "$HOME/.dotfiles/.tmux.conf" "$HOME/.byoburc.tmux"

# Keep EC2 connections from periodically hanging up
sudo echo "KeepAlive yes" >> /etc/ssh/sshd_config
sudo echo "ClientAliveInterval 60" >> /etc/ssh/sshd_config

# Install Steve Francia's awesome vim config
curl --insecure http://j.mp/spf13-vim3 -L -o - | sh
ln -s "$HOME/.dotfiles/.vimrc.local" "$HOME/.vimrc.local"
ln -s "$HOME/.dotfiles/.vimrc.bundles.local" "$HOME/.vimrc.bundles.local"

# Done!
echo "All done! Log out of all open sessions to install new env!"
