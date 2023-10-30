# shellcheck shell=bash
about-completion "bash parameter completion for the dotnet CLI"
# see https://docs.microsoft.com/en-us/dotnet/core/tools/enable-tab-autocomplete#bash

function _dotnet_bash_complete() {
	local cur="${COMP_WORDS[COMP_CWORD]}" IFS=$'\n'
	local candidates

	read -d '' -ra candidates < <(dotnet complete --position "${COMP_POINT}" "${COMP_LINE}" 2> /dev/null)

	read -d '' -ra COMPREPLY < <(compgen -W "${candidates[*]:-}" -- "$cur")
}

complete -f -F _dotnet_bash_complete dotnet
