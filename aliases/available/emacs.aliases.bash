#!/bin/bash

case $OSTYPE in
    linux*)
        alias e='emacsclient -a emacs -n'
        alias em='emacsclient -a emacs'
        alias E="SUDO_EDITOR=\"emacsclient -c -a emacs\" sudoedit"
        ;;
    darwin*)
        alias em="open -a emacs"
        ;;
esac
