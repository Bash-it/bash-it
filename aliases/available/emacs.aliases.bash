cite 'about-alias'
about-alias 'emacs editor'

case $OSTYPE in
  linux*)
    alias em='emacs'
    alias en='emacs -t'
    alias e='emacsclient -n'
    alias et='emacsclient -t'
    alias ed='emacs --debug-init'
    alias ew='emacsclient -c'
    alias E='SUDO_EDITOR=emacsclient sudo -e'
    ;;
  darwin*)
    alias em='open -a emacs'
    ;;
esac
