# OS-Specific Configs ---------------------------------------------------------
osname=`uname`
if [[ "$osname" == 'Linux' ]]; then
    source $HOME/.linuxrc
elif [[ "$osname" == 'Darwin' ]]; then
    source $HOME/.osxrc
fi

# Work Sources ----------------------------------------------------------------
source_if_exists $PRIVATE/dotfiles/.workrc
source_if_exists $PRIVATE/dotfiles/.dockerrc

# vim: set filetype=sh:

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Funktions -------------------------------------------------------------------
warn() {
  print -u2 -- "Warning: $*"
}

# Package Manager(s) Init -----------------------------------------------------
eval "$(direnv hook zsh)"

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

# Command search --------------------------------------------------------------
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "$terminfo[kcuu1]" up-line-or-beginning-search
bindkey "$terminfo[kcud1]" down-line-or-beginning-search

# Error Checking --------------------------------------------------------------
if (( ! ${+PRIVATE} )); then
  warn "Variable PRIVATE is not defined for this platform!"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
