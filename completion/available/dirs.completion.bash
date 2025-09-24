# shellcheck shell=bash
about-completion "Bash completion support for the 'dirs' plugin (commands G, R)."

function _dirs-complete() {
	# parse all defined shortcuts ${BASH_IT_DIRS_BKS}
	if [[ -s "${BASH_IT_DIRS_BKS:-/dev/null}" ]]; then
		IFS=$'\n' read -d '' -ra COMPREPLY < <(grep -v '^#' "${BASH_IT_DIRS_BKS?}" | sed -e 's/\(.*\)=.*/\1/')
	fi

	return 0
}

complete -o default -o nospace -F _dirs-complete -X '!&*' G R
