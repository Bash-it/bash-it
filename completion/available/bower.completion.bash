#!/usr/bin/env bash
# Bash completion support for Bower.

export COMP_WORDBREAKS=${COMP_WORDBREAKS/\:/}

_bower_cmds=" \
cache \
help \
home \
info \
init \
install \
link \
list \
lookup \
prune \
register \
search \
update \
uninstall"

_bowercomplete() {
	COMPREPLY=($(compgen -W "${_bower_cmds}" -- ${COMP_WORDS[COMP_CWORD]}))
	return 0
}

complete -F _bowercomplete bower
