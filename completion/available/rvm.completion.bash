#!/usr/bin/env bash
# Bash completion support for  RVM.


_rvm_complete() {
	[[ -r $rvm_path/scripts/completion ]] && . $rvm_path/scripts/completion
}

complete -o default -o nospace -F _rvm_complete rvm
