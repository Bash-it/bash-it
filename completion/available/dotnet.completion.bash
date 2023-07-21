# shellcheck shell=bash
about-completion "bash parameter completion for the dotnet CLI"
# see https://docs.microsoft.com/en-us/dotnet/core/tools/enable-tab-autocomplete#bash

function _dotnet_bash_complete() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################

	local cur="${COMP_WORDS[COMP_CWORD]}" IFS=$'\n'
	local candidates

	read -d '' -ra candidates < <(dotnet complete --position "${COMP_POINT}" "${COMP_LINE}" 2> /dev/null)

	read -d '' -ra COMPREPLY < <(compgen -W "${candidates[*]:-}" -- "$cur")
	
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}

complete -f -F _dotnet_bash_complete dotnet
