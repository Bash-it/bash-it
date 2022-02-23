# shellcheck shell=bash

# Make sure dmidecode is installed
_bash-it-completion-helper-necessary dmidecode || :

# Don't handle completion if it's already managed
_bash-it-completion-helper-sufficient dmidecode || return

function _dmidecode() {
	local prev="${COMP_WORDS[COMP_CWORD - 1]}"

	case $prev in
		-s | --string | -t | --type)
			OPTS=$(dmidecode "$prev" 2>&1 | grep -E '^ ' | sed 's/ *//g')
			# shellcheck disable=SC2207
			COMPREPLY=("${OPTS[@]}")
			;;
		dmidecode)
			# shellcheck disable=SC2207
			COMPREPLY=("-d" "--dev-mem" "-h" "--help" "-q" "--quiet" "-s" "--string" "-t" "--type" "-H" "--handle" "-u" "--dump" "-dump-bin" "--from-dump" "--no-sysfs" "--oem-string" "-V" "--version")
			;;
	esac
}

complete -F _dmidecode -X '!&*' dmidecode
