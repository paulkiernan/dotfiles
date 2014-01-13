export TERM=xterm-256color

export ZSH="$HOME/.dotfiles/oh-my-zsh"
export ZSH_THEME="afowler"
export DISABLE_AUTO_UPDATE="true"
export OH_MY_ZSH_DEBUG="true"
plugins=(command-coloring pip fabric lein redis-cli vagrant)

source $ZSH/oh-my-zsh.sh

# Custom options -------------------------------------------------------------
unsetopt promptcr

# Terminal vim bindings
set -o vi

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
alias hi='pygmentize'
alias jsonp='python -mjson.tool | pygmentize -l javascript;'
alias fact="elinks -dump randomfunfacts.com | sed -n '/^| /p' | tr -d \|"
alias glr='fact && git pull'

function gimmeurjson() { curl "$*" | python -mjson.tool | pygmentize -l javascript; }

# Environment variables ------------------------------------------------------
export EDITOR='vim'
export PATH="$HOME/bin:/usr/local/bin:/usr/local/sbin:/opt/local/bin:$PATH"
export GREP_OPTIONS='--color=auto'
export HISTSIZE=1000
export HISTFILESIZE=1000
export HISTCONTROL=erasedups
export COMMAND_MODE=unix2003
export DISABLE_AUTO_TITLE="true" #Fix where tmux would always autorename

# Python variables -----------------------------------------------------------
export PIP_DOWNLOAD_CACHE="$HOME/.pip/cache"
export PATH="${PATH}:/Developer/usr/bin"
export PATH="${PATH}/usr/local/heroku/bin"
export PYTHONPATH="$PYTHONPATH:/usr/local/lib/python2.7/site-packages"
export PYTHONPATH="$PYTHONPATH:/usr/local/Cellar/python/2.7.1/lib/python2.7/site-packages"

# Heroku stuff
export WORKON_HOME=$HOME/.virtualenvs
export VIRTUALENVWRAPPER_SCRIPT=/usr/local/bin/virtualenvwrapper.sh
source /usr/local/bin/virtualenvwrapper_lazy.sh

# Extra ----------------------------------------------------------------------
source ~/.dotfiles/z/z.sh

# Pre-Prompt Command ---------------------------------------------------------
function precmd () {
    z --add "$(pwd -P)"
}

# Local Settings -------------------------------------------------------------
if [[ -s $HOME/.zshrc_local ]] ; then source $HOME/.zshrc_local ; fi

# Moat Settings --------------------------------------------------------------
source /mnt/common/scripts/glom.sh master.bots
alias discover="/mnt/common/registry/discover.py"
alias update_tagcache="/mnt/scrapepipeline/scrapepipeline/cache/tagcache.py --prefix=prod"

# LS aliases
alias l1='tree --dirsfirst -ChFL 1'
alias l2='tree --dirsfirst -ChFL 2'
alias l3='tree --dirsfirst -ChFL 3'

alias ll1='tree --dirsfirst -ChFupDaL 1'
alias ll2='tree --dirsfirst -ChFupDaL 2'
alias ll3='tree --dirsfirst -ChFupDaL 3'

alias l='l1'
alias ll='ll1'
