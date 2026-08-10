# Le Basics -------------------------------------------------------------------
export TERM=xterm-256color
export VISUAL=vim
export EDITOR="$VISUAL"

# Personalization -------------------------------------------------------------
export SOPS_AGE_KEY_FILE=$HOME/.config/sops/age/keys.txt
export AWS_SDK_LOAD_CONFIG=true

# PATH Manipulation -----------------------------------------------------------
export PATH="${PRIVATE:+$PRIVATE/scripts:}${PATH}"
export PATH="$HOME/.asdf/bin:$PATH"
export PATH="$HOME/.asdf/shims:$PATH"
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
export ZSH_THEME="powerlevel10k/powerlevel10k"

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
alias ytdl="yt-dlp -x --audio-format mp3 --audio-quality 0"

# Useless aliases -------------------------------------------------------------
alias fact="~/scripts/getfact.sh"
alias factbomb='for run in {1..100}; do; fact; echo ---; done'

# Work Sources ----------------------------------------------------------------
source_if_exists() {
    # check file exists, is regular file and is readable:
    if [[ -f $1 && -r $1 ]]; then
        source $1
    fi
}

source_if_exists $PRIVATE/dotfiles/.workrc
source_if_exists $PRIVATE/dotfiles/.dockerrc
source_if_exists $HOME/.asdf/plugins/java/set-java-home.zsh
source_if_exists $HOME/.p10k.zsh

# Added by Antigravity
export PATH="/Users/paul/.antigravity/antigravity/bin:$PATH"
