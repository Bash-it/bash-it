# shellcheck shell=bash

# Make sure notify-send is installed
_bash-it-completion-helper-necessary notify-send || :

# Don't handle completion if it's already managed
_bash-it-completion-helper-sufficient notify-send || return

function _notify-send() {
	local prev="${COMP_WORDS[COMP_CWORD - 1]}"

	case $prev in
		-u | --urgency)
			COMPREPLY=("low" "normal" "critical")
			;;
		*)
			COMPREPLY=("-?" "--help" "-u" "--urgency" "-t" "--expire-time" "-a" "--app-name" "-i" "--icon" "-c" "--category" "-h" "--hint" "-v" "--version")
			;;
	esac
}

complete -F _notify-send -X '!&*' notify-send
