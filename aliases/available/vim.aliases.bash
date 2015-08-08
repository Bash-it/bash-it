cite 'about-alias'
about-alias 'vim abbreviations'

VIM=$(command -v vim)
GVIM=$(command -v gvim)
MVIM=$(command -v mvim)

[[ -n $VIM ]] && alias v=$VIM

case $OSTYPE in
  darwin*)
    [[ -n $MVIM ]] && alias mvimt="mvim --remote-tab"
    ;;
  *)
    [[ -n $GVIM ]] && alias gvimt="gvim --remote-tab"
    ;;
esac
