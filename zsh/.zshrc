# vim: set filetype=sh:

# Le Basics -------------------------------------------------------------------
export TERM=xterm-256color
export VISUAL=vim
export EDITOR="$VISUAL"

# Personalization -------------------------------------------------------------
export SOPS_AGE_KEY_FILE=$HOME/.config/sops/age/keys.txt
export AWS_SDK_LOAD_CONFIG=true

# Funktions -------------------------------------------------------------------
source_if_exists() {
    # check file exists, is regular file and is readable:
    if [[ -f $1 && -r $1 ]]; then
        source $1
    fi
}

warn() {
  print -u2 -- "Warning: $*"
}

# Package Manager(s) Init -----------------------------------------------------
export ASDF_DATA_DIR="/$HOME/.asdf"
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"
eval "$(pyenv virtualenv-init -)"
eval "$(direnv hook zsh)"

# PATH Manipulation -----------------------------------------------------------
export PATH="${PRIVATE}/scripts:${PATH}"
export PATH="$HOME/.asdf/bin:$PATH"
export PATH="$ASDF_DATA_DIR/shims:$PATH"
export PATH="${HOME}/usr/local:${PATH}"
export PATH="${HOME}/.local/bin:${PATH}"
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# ZSH Config ------------------------------------------------------------------
export HISTFILE=~/.zhistory
export HISTSIZE=100000
export REPORTTIME=10

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
zstyle ':completion:*:*:*:*:*files' ignored-patterns '*.pyc'

set -o vi
bindkey -v

# Autocompletion --------------------------------------------------------------
autoload -Uz compinit
compinit

# Useful aliases --------------------------------------------------------------
alias c='clear'
alias r='reset'
alias json='python -mjson.tool | pygmentize -l json'
alias vimupdate="vim +BundleInstall! +BundleClean"
alias ogless="less"
alias less="pygmentize -O style=monokai | less"

alias ll1='tree --dirsfirst -ChFupDaL 1'
alias ll2='tree --dirsfirst -ChFupDaL 2'
alias ll3='tree --dirsfirst -ChFupDaL 3'
alias ll='ll1'

alias cdp="cd $HOME/workspace/github.com/paulkiernan"

alias superslicer="/Applications/SuperSlicer.app/Contents/MacOS/SuperSlicer --datadir ${HOME}/workspace/github.com/paulkiernan/voron/superslicer"

alias ytdl="yt-dlp -x --audio-format mp3 --audio-quality 0"

# Useless aliases -------------------------------------------------------------
alias fact="~/scripts/getfact.sh"
alias factbomb='for run in {1..100}; do; fact; echo ---; done'
alias glr='fact && git pull'
alias nyan='nyancat'

# Work Sources ----------------------------------------------------------------
source_if_exists $PRIVATE/dotfiles/.workrc
source_if_exists $PRIVATE/dotfiles/.dockerrc

# Command search --------------------------------------------------------------
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "$terminfo[kcuu1]" up-line-or-beginning-search
bindkey "$terminfo[kcud1]" down-line-or-beginning-search

# OS-Specific Configs ---------------------------------------------------------
osname=`uname`
if [[ "$osname" == 'Linux' ]]; then
    source $HOME/.linuxrc
elif [[ "$osname" == 'Darwin' ]]; then
    source $HOME/.osxrc
fi

# Error Checking --------------------------------------------------------------
if (( ! ${+PRIVATE} )); then
  warn "Variable PRIVATE is not defined for this platform!"
fi
