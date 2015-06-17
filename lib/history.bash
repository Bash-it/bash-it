#!/usr/bin/env bash

# Bash History Handling

shopt -s histappend              # append to bash_history if Terminal.app quits
export HISTCONTROL=erasedups     # erase duplicates; alternative option: export HISTCONTROL=ignoredups
export HISTSIZE=5000             # resize history size
export AUTOFEATURE=true autotest

function rh {
  history | awk '{a[$2]++}END{for(i in a){print a[i] " " i}}' | sort -rn | head
}
