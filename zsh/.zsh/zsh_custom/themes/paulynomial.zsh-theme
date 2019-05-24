if [ $UID -eq 0 ]; then CARETCOLOR="red"; else CARETCOLOR="cyan"; fi

local return_code="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"

#PROMPT='[%D %T @ %M] %{${fg_bold[blue]}%}:: %{$reset_color%}%{${fg[green]}%}%3~$(git-radar --zsh --fetch) %{${fg_bold[$CARETCOLOR]}%}λ%{${reset_color}%}  '
PROMPT='[%D %T @ %M] %{${fg_bold[blue]}%}:: %{$reset_color%}%{${fg[green]}%}%3~ $(githud zsh) %{${fg_bold[$CARETCOLOR]}%}λ%{${reset_color}%}  '
#PROMPT='[%D %T @ %M] %{${fg_bold[blue]}%}:: %{$reset_color%}%{${fg[green]}%}%3~ GIT BROKE %{${fg_bold[$CARETCOLOR]}%}λ%{${reset_color}%}  '

RPS1="${return_code}"

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[yellow]%}‹"
ZSH_THEME_GIT_PROMPT_SUFFIX="› %{$reset_color%}"
