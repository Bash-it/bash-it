# shellcheck shell=bash

function __notify-send_completions() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	# shellcheck disable=SC2155
	local curr=$(_get_cword)
	# shellcheck disable=SC2155
	local prev=$(_get_pword)

	case $prev in
		-u | --urgency)
			# shellcheck disable=SC2207
			COMPREPLY=($(compgen -W "low normal critical" -- "$curr"))
			;;
		*)
			# shellcheck disable=SC2207
			COMPREPLY=($(compgen -W "-? --help -u --urgency -t --expire-time -a --app-name -i --icon -c --category -h --hint -v --version" -- "$curr"))
			;;
	esac
	
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}

complete -F __notify-send_completions notify-send
