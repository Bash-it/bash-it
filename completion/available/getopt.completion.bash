# shellcheck shell=bash

function _getopt() {
	local IFS=$'\n'
	local cur=${COMP_WORDS[COMP_CWORD]}
	local prev=${COMP_WORDS[COMP_CWORD-1]:-}

	local OPTIONS=('-a' '--alternative'
		'-h' '--help'
		'-l' '--longoptions'
		'-n' '--name'
		'-o' '--options'
		'-q' '--quiet'
		'-Q' '--quiet-output'
		'-s' '--shell'
		'-T' '--test'
		'-u' '--unquoted'
		'-V' '--version')

	local SHELL_ARGS=('sh' 'bash' 'csh' 'tcsh')

	case $prev in
		-s | --shell)
			COMPREPLY=("${SHELL_ARGS[@]}")
			;;
		-n | --name)
			read -d '' -ra COMPREPLY < <(compgen -A function -- "$cur")
			;;
		*)
			COMPREPLY=("${OPTIONS[@]}")
			;;
	esac
}

complete -F _getopt -X '!&*' getopt
