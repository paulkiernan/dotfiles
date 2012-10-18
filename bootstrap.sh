# Use this file to (re)build a familiar command line env
# run "wget --no-check-certificate https://github.com/paulkiernan/dotfiles/raw/master/bootstrap.sh -O - | sh"

# Don't forget the SSH keys.
# Need to sudo to sucessfully apt-get

# TODO: Set byobu-backend default to tmux
# TODO: Add byobu-tmux default
# TODO: Add vim.local defaults to this repo

echo "Creating the local lib directory for dotfiles"
mkdir ~/lib/

# Install essential dev tools
sudo apt-get -y install sl build-essential bash-completion curl git-core git-flow zsh vim byobu
# Install python tools
sudo apt-get -y install ipython bpython python-setuptools python-dev python-pip

# Install these dotfiles locally
git clone https://github.com/paulkiernan/dotfiles $HOME/lib/dotfiles

# Install ZSH stuff
echo "Installing ZSH"
chsh -s /bin/zsh
git clone git://github.com/sjl/oh-my-zsh $HOME/lib/oh-my-zsh
git clone git://github.com/sjl/z-zsh $HOME/lib/z
rm ~/.zshrc
ln -s "$HOME/lib/dotfiles/.zshrc" "$HOME/.zshrc"
ln -s "$HOME/lib/dotfiles/zsh" "$HOME/lib/oh-my-zsh/custom"

# Install git-flow
git clone git://github.com/bobthecow/git-flow-completion.git $HOME/lib/git-flow-completion

# Install other config settings
rm "$HOME/.gitconfig"
ln -s "$HOME/lib/dotfiles/.gitconfig" "$HOME/.gitconfig"

# Keep EC2 connections from periodically hanging up
sudo echo "KeepAlive yes" >> /etc/ssh/sshd_config
sudo echo "ClientAliveInterval 60" >> /etc/ssh/sshd_config

# Install Steve Francia's awesome vim config
curl http://j.mp/spf13-vim3 -L -o - | sh

# Done!
echo "All done! Log out of all open sessions to install new env!"
