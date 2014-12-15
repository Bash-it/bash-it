cite 'about-alias'
about-alias 'vim abbreviations'

VIM=$(command -v vim)
GVIM=$(command -v gvim)
MVIM=$(command -v mvim)

[[ -n $VIM ]] && alias v=$VIM

case $ostype in
  darwin*)
    [[ -n $MVIM ]] && alias vim="mvim --remote-tab"
    ;;
  *)
    [[ -n $GVIM ]] && alias gvim="gvim -b --remote-tab"
    ;;
esac
