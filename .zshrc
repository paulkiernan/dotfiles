# Base Terminal Config
# vim: set filetype=sh:

export TERM=xterm-256color

export ZSH="$HOME/.dotfiles/oh-my-zsh"
export ZSH_CUSTOM="$HOME/.dotfiles/zsh-custom"
export ZSH_THEME="paulynomial"
export DISABLE_AUTO_UPDATE="true"
export OH_MY_ZSH_DEBUG="true"
plugins=(brew colored-man colorize command-coloring git-prompt pep8 nyan vagrant)

[ -s "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"

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
alias vimupdate="vim +BundleInstall! +BundleClean"

# Useless aliases ------------------------------------------------------------
alias hi='pygmentize'
alias json='python -mjson.tool | pygmentize -l json;'
alias fact="elinks -dump randomfunfacts.com | sed -n '/^| /p' | tr -d \|"
alias glr='fact && git pull'

function gimmeurjson() {
    curl "$*" | python -mjson.tool | pygmentize -l javascript;
}

# Environment variables ------------------------------------------------------
export EDITOR='vim'
export PATH="$HOME/.dotfiles/scripts:$HOME/bin:/usr/local/bin:/usr/local/sbin:/opt/local/bin:$PATH"
export GREP_OPTIONS='--color=auto'
export HISTFILE=~/.zhistory
export HISTSIZE=10000
export HISTFILESIZE=10000
export HISTCONTROL=erasedups
export COMMAND_MODE=unix2003
export DISABLE_AUTO_TITLE="true" #Fix where tmux would always autorename
export REPORTTIME=10

# ZSH Config -----------------------------------------------------------------
setopt incappendhistory
setopt sharehistory
setopt extendedhistory

# Python stuff ---------------------------------------------------------------
export PIP_DOWNLOAD_CACHE="$HOME/.pip/cache"
export PATH="${PATH}:/Developer/usr/bin"
# CD into a python package's source dir
cdp () {
    cd "$(python -c "import os.path as _, ${1}; \
        print(_.dirname(_.realpath(${1}.__file__[:-1])))"
    )"
}

# Ruby PATH variables --------------------------------------------------------
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# Heroku stuff
export PATH="${PATH}/usr/local/heroku/bin"
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/Desktop/Experiments
export VIRTUALENVWRAPPER_SCRIPT=/usr/local/bin/virtualenvwrapper.sh
source /usr/local/bin/virtualenvwrapper_lazy.sh
source /usr/local/opt/autoenv/activate.sh       # Load Autoenv

# Extra ----------------------------------------------------------------------
source ~/.dotfiles/z/z.sh
export BYOBU_PREFIX=$(brew --prefix)

# Pre-Prompt Command ---------------------------------------------------------
function precmd () {
    z --add "$(pwd -P)"
}

# Local Settings -------------------------------------------------------------
if [[ -s $HOME/.zshrc_local ]] ; then source $HOME/.zshrc_local ; fi

# LS aliases
alias l1='tree --dirsfirst -ChFL 1'
alias l2='tree --dirsfirst -ChFL 2'
alias l3='tree --dirsfirst -ChFL 3'

alias ll1='tree --dirsfirst -ChFupDaL 1'
alias ll2='tree --dirsfirst -ChFupDaL 2'
alias ll3='tree --dirsfirst -ChFupDaL 3'

alias l='l1'
alias ll='ll1'

source-if-exists() {
    # check file exists, is regular file and is readable:
    if [[ -f $1 && -r $1 ]]; then
        source $1
    fi
}

# Work Sources ---------------------------------------------------------------
source-if-exists $HOME/.workrc

# Docker Sources -------------------------------------------------------------
source-if-exists $HOME/.dockerrc
