export ZSH="$HOME/lib/oh-my-zsh"
export ZSH_THEME="afowler"
export DISABLE_AUTO_UPDATE="true"
export OH_MY_ZSH_DEBUG="true"
plugins=(command-coloring pip fabric lein redis-cli vagrant)

source $ZSH/oh-my-zsh.sh

# Custom options -------------------------------------------------------------
unsetopt promptcr

# Useful aliases -------------------------------------------------------------
alias j='z'
alias tm='tmux -u2'
alias c='clear'
alias bp='bpython'
alias ll='ls -lah'
alias sane='stty sane'
alias external_ip="curl -s http://checkip.dyndns.org | sed 's/[a-zA-Z/<> :]//g'"
alias vimupdate="vim +BundleInstall! +BundleClean +q" # For reconfiguring vim

# Useless aliases ------------------------------------------------------------
alias fact="elinks -dump randomfunfacts.com | sed -n '/^| /p' | tr -d \|"
alias glr='fact && git pull'

# Environment variables ------------------------------------------------------
export EDITOR='vim'
export PATH="$HOME/bin:/usr/local/bin:/usr/local/sbin:/opt/local/bin:$PATH"
export GREP_OPTIONS='--color=auto'
export HISTSIZE=1000
export HISTFILESIZE=1000
export HISTCONTROL=erasedups
export COMMAND_MODE=unix2003
export DISABLE_AUTO_TITLE="true" #Fix where tmux would always autorename

# MacPorts Variables
export PATH=$PATH:/opt/local/bin/
export PATH=$PATH:/opt/local/include

# Python variables -----------------------------------------------------------
export PIP_DOWNLOAD_CACHE="$HOME/.pip/cache"
export PYTHONSTARTUP="$HOME/.pythonrc.py"
export WORKON_HOME="${HOME}/lib/virtualenvs"
export PATH="${PATH}:/Developer/usr/bin/"
export PATH="${PATH}:/usr/local/share/python/"
export PATH="${PATH}:$HOME/.lein/bin"
export PYTHONPATH="$PYTHONPATH:/usr/local/Cellar/python/2.7.1/lib/python2.7/site-packages"
export PYTHONPATH="$PYTHONPATH:/usr/local/lib/python2.7.1/site-packages"
export PYTHONPATH="$PYTHONPATH:/usr/local/lib/python2.7/site-packages"
export PYTHONPATH="$PYTHONPATH:/usr/local/lib/python2.6/site-packages"
export VEW_PATH="$HOME/lib/python/virtualenvwrapper/virtualenvwrapper.sh"
export PYTHONPATH="$HOME/lib/python/see:$PYTHONPATH"
export NODE_PATH="$NODE_PATH:/usr/local/lib/node:/usr/local/lib/node_modules"

# Extra ----------------------------------------------------------------------
source ~/lib/z/z.sh

# Pre-Prompt Command ---------------------------------------------------------
function precmd () {
    z --add "$(pwd -P)"
}

# Local Settings -------------------------------------------------------------
if [[ -s $HOME/.zshrc_local ]] ; then source $HOME/.zshrc_local ; fi

# Moat Settings --------------------------------------------------------------
source /mnt/common/scripts/glom.sh master.bots
