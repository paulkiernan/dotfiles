# vim: set filetype=sh:

# Le Basics -------------------------------------------------------------------
export TERM=xterm-256color
export VISUAL=vim
export EDITOR="$VISUAL"

# Variable Defs ---------------------------------------------------------------
export PRIVATE=$HOME/Dropbox/private

# Funktions --------------------------------------------------------------------
source-if-exists() {
    # check file exists, is regular file and is readable:
    if [[ -f $1 && -r $1 ]]; then
        source $1
    fi
}

# PATH Manipulation -----------------------------------------------------------
export ASDF_DIR="$HOME/.asdf"
export PATH="${PRIVATE}/scripts:${PATH}"

# ZSH Config -------------------------------------------------------------------
export ZSH="$HOME/.zsh/oh-my-zsh"
export DISABLE_AUTO_UPDATE="true"
export OH_MY_ZSH_DEBUG="true"
export ZSH_CUSTOM="$HOME/.zsh/zsh_custom"
export ZSH_THEME="paulynomial"
[ -s "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"
plugins=(
    colored-man-pages
    colorize
    history
    vi-mode
)
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
unsetopt PROMPT_CR
export HISTFILE=~/.zhistory
export HISTSIZE=100000
export REPORTTIME=10
zstyle ':completion:*:*:*:*:*files' ignored-patterns '*.pyc'

# Useful aliases ---------------------------------------------------------------
alias c='clear'
alias r='reset'
alias json='python -mjson.tool | pygmentize -l json;'
alias external_ip="curl -s http://checkip.dyndns.org | sed 's/[a-zA-Z/<> :]//g'"
alias vimupdate="vim +BundleInstall! +BundleClean"

alias ll1='tree --dirsfirst -ChFupDaL 1'
alias ll2='tree --dirsfirst -ChFupDaL 2'
alias ll3='tree --dirsfirst -ChFupDaL 3'
alias ll='ll1'

# Useless aliases --------------------------------------------------------------
alias fact='wget randomfunfacts.com -O - 2>/dev/null | grep \<strong\> | sed "s;^.*<i>\(.*\)</i>.*$;\1;" | fmt --width=80'
alias factbomb='for run in {1..100}; do; fact; echo ---; done'
alias glr='fact && git pull'
alias nyan='nyancat'

# Work Sources -----------------------------------------------------------------
source-if-exists $PRIVATE/dotfiles/.workrc
source-if-exists $PRIVATE/dotfiles/.dockerrc
source $ASDF_DIR/asdf.sh
fpath=(${ASDF_DIR}/completions $fpath)
autoload -Uz compinit
compinit

# Fork ------------------------------------------------------------------------
osname=`uname`
if [[ "$osname" == 'Linux' ]]; then
    source $HOME/.linuxrc
elif [[ "$osname" == 'Darwin' ]]; then
    source $HOME/.osxrc
fi

set -o vi
bindkey -v
