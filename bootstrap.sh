
# Use this file to (re)build a familiar command line env
# run "wget --no-check-certificate https://github.com/paulkiernan/dotfiles/raw/master/bootstrap.sh -O - | sh"

# THIS IS A WORK IN PROGRESS
# BE CAREFUL, DAMMIT

# Don't forget the SSH keys.
# Need to sudo to sucessfully apt-get

mkdir ~/lib/

sudo apt-get update
sudo apt-get upgrade
sudo apt-get -y install sl build-essential git zsh vim ipython python-setuptools

git clone git://github.com/sjl/oh-my-zsh ~/lib/oh-my-zsh
git clone git://github.com/sjl/z-zsh ~/lib/z
git clone git://github.com/nvie/gitflow.git ~/lib/git-flow
git clone git://github.com/bobthecow/git-flow-completion.git ~/lib/git-flow-completion

cd lib/

git clone https://github.com/paulkiernan/dotfiles

cd

sudo pip install numpy

ln -s "$HOME/lib/dotfiles/zsh" "$HOME/lib/oh-my-zsh/custom"

ln -s "$HOME/lib/dotfiles/.ackrc" "$HOME/.ackrc"
ln -s "$HOME/lib/dotfiles/.gitconfig" "$HOME/.gitconfig"
ln -s "$HOME/lib/dotfiles/.hgrc" "$HOME/.hgrc"
ln -s "$HOME/lib/dotfiles/vim" "$HOME/.vim"
ln -s "$HOME/lib/dotfiles/vim/.vimrc" "$HOME/.vimrc"
ln -s "$HOME/lib/dotfiles/.screenrc" "$HOME/.screenrc"

rm ~/.zshrc
rm ~/.bashrc
rm ~/.bash_profile
ln -s "$HOME/lib/dotfiles/.zshrc" "$HOME/.zshrc"

sudo echo "KeepAlive yes" >> /etc/ssh/sshd_config
sudo echo "ClientAliveInterval 60" >> /etc/ssh/sshd_config

