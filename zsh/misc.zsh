alias hi='pygmentize'
alias sane='stty sane'
alias external_ip="curl -s http://checkip.dyndns.org | sed 's/[a-zA-Z/<> :]//g'"
alias vimupdate="vim +BundleInstall! +BundleClean +q" # For reconfiguring vim

# Useless aliases ------------------------------------------------------------
alias fact="elinks -dump randomfunfacts.com | sed -n '/^| /p' | tr -d \|"
alias glr='fact && git pull'

function gimmeurjson() { curl "$*" | python -mjson.tool | pygmentize -l javascript; }
