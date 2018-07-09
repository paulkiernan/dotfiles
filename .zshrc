# vim: set filetype=sh:
export TERM=xterm-256color

# Funktions --------------------------------------------------------------------
source-if-exists() {
    # check file exists, is regular file and is readable:
    if [[ -f $1 && -r $1 ]]; then
        source $1
    fi
}

# ZSH Config -------------------------------------------------------------------
export ZSH="$HOME/.dotfiles/oh-my-zsh"
export ZSH_CUSTOM="$HOME/.dotfiles/zsh-custom"
export ZSH_THEME="paulynomial"
export DISABLE_AUTO_UPDATE="true"
export OH_MY_ZSH_DEBUG="true"
[ -s "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"
plugins=(
    brew
    colored-man-pages
    history
    pyenv
    ssh-agent
    zsh-syntax-highlighting
)
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
unsetopt PROMPT_CR
export HISTFILE=~/.zhistory
export HISTSIZE=100000
export REPORTTIME=10

# Useful aliases ---------------------------------------------------------------
alias c='clear'
alias r='reset'
alias json='python -mjson.tool | pygmentize -l json;'
alias my_ip="curl -s http://checkip.dyndns.org | sed 's/[a-zA-Z/<> :]//g'"
alias tmux="byobu-tmux"
alias vimupdate="vim +BundleInstall! +BundleClean"


# Useless aliases --------------------------------------------------------------
alias fact="gtimeout 1 elinks -dump randomfunfacts.com | sed -n '/^| /p' | tr -d \|"
alias factbomb="for run in {1..5}; do; fact; echo ---; done"
alias glr='fact && git pull'
alias nyan='telnet nyancat.dakko.us'

# Environment variables --------------------------------------------------------
## PATH Priority list
export PATH="${HOME}/.dotfiles/scripts:${PATH}"
export PATH="${HOME}/.git-radar/:${PATH}"
export PATH="/bin:$PATH"
export PATH="/sbin:$PATH"
export PATH="/usr/bin:$PATH"
export PATH="/usr/sbin:$PATH"
export PATH="/usr/local/bin:$PATH"
export PATH="/usr/local/sbin:$PATH"
export PATH="/usr/local/opt/python/libexec/bin:${PATH}"
export PATH="${PATH}:/usr/local/CrossPack-AVR/bin/"  # Arduino + teensy devel

# Python stuff -----------------------------------------------------------------
if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi

# LS aliases
alias ll1='tree --dirsfirst -ChFupDaL 1'
alias ll2='tree --dirsfirst -ChFupDaL 2'
alias ll3='tree --dirsfirst -ChFupDaL 3'
alias ll='ll1'

# Work Sources -----------------------------------------------------------------
source-if-exists $HOME/.workrc

# Docker Sources ---------------------------------------------------------------
source-if-exists $HOME/.dockerrc

# VIM lyfe ---------------------------------------------------------------------
export EDITOR='vim'
set -o vi
bindkey -v

# Terminal MOTD ----------------------------------------------------------------
if ! [ -x "$(command -v archey)" ]; then
    echo 'Error: archey is not installed.' >&2
else
    archey -c
fi

if ! [ -x "$(command -v g)" ]; then
    echo 'Error: gtimeout is not installed.' >&2
else
    echo "Learn something:\n"
    fact
fi
