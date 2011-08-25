#!/bin/bash

case $OSTYPE in
  linux*)
    alias em='emacs'
    alias e='emacsclient -n'
    ;;
  darwin*)
    alias em="open -a emacs"
    ;;
esac
