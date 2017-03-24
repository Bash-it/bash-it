#!/usr/bin/env bash
# Bash completion support for  RVM.
# Source: https://rvm.io/workflow/completion


_rvm_complete() {
	[[ -r $rvm_path/scripts/completion ]] && . $rvm_path/scripts/completion
}
