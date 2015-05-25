cite 'about-alias'
about-alias 'Tmux terminal multiplexer'

case $OSTYPE in
  linux*)
    alias txl='tmux ls'
    alias txn='tmux new -s'
    alias txa='tmux a -t'
    ;;
esac
