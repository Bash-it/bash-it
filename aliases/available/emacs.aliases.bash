cite 'about-alias'
about-alias 'emacs editor'

case $OSTYPE in
  linux*)
    alias em='emacs'
    alias e='emacsclient -n'
    alias E="SUDO_EDITOR=\"emacsclient -c -a emacs\" sudoedit"
    ;;
  darwin*)
    alias em='open -a emacs'
    ;;
esac
