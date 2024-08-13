# vim: set filetype=sh:

# Le Basics -------------------------------------------------------------------
export TERM=xterm-256color
export VISUAL=vim
export EDITOR="$VISUAL"

# Variable Defs ---------------------------------------------------------------
export PRIVATE="/Users/paul/Dropbox/private"

# Funktions --------------------------------------------------------------------
source-if-exists() {
    # check file exists, is regular file and is readable:
    if [[ -f $1 && -r $1 ]]; then
        source $1
    fi
}

# PATH Manipulation -----------------------------------------------------------
export ASDF_DIR="$HOME/.asdf"
export PATH="/opt/homebrew/bin:${PATH}"
export PATH="${PRIVATE}/scripts:${PATH}"
export PATH="${HOME}/usr/local:${PATH}"
export PATH="${HOME}/.local/bin:${PATH}"

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

export PATH="${PATH}:/Users/paul.kiernan/.asdf/installs/haskell/8.10.7/bin"

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
    poetry
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
alias json='python -mjson.tool | pygmentize -l json'
alias external_ip="curl -s http://checkip.dyndns.org | sed 's/[a-zA-Z/<> :]//g'"
alias vimupdate="vim +BundleInstall! +BundleClean"
alias ogless="less"
alias less="pygmentize -O style=monokai | less"

alias ll1='tree --dirsfirst -ChFupDaL 1'
alias ll2='tree --dirsfirst -ChFupDaL 2'
alias ll3='tree --dirsfirst -ChFupDaL 3'
alias ll='ll1'

alias cdp="cd $HOME/workspace/github.com/paulkiernan"

# Useless aliases --------------------------------------------------------------
alias fact="~/scripts/getfact.sh"
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

source ~/.asdf/plugins/java/set-java-home.zsh
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# Fork ------------------------------------------------------------------------
osname=`uname`
if [[ "$osname" == 'Linux' ]]; then
    source $HOME/.linuxrc
elif [[ "$osname" == 'Darwin' ]]; then
    source $HOME/.osxrc
fi

set -o vi
bindkey -v

# Command search --------------------------------------------------------------
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "$terminfo[kcuu1]" up-line-or-beginning-search
bindkey "$terminfo[kcud1]" down-line-or-beginning-search

export SOPS_AGE_KEY_FILE=$HOME/.config/sops/age/keys.txt
eval "$(direnv hook zsh)"

export AWS_SDK_LOAD_CONFIG=true

# 3D Printing -----------------------------------------------------------------
alias superslicer="/Applications/SuperSlicer.app/Contents/MacOS/SuperSlicer --datadir ${HOME}/workspace/github.com/paulkiernan/voron/superslicer"

alias ytdl="yt-dlp -x --audio-format mp3 --audio-quality 0"
