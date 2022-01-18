# shellcheck shell=bash
about-plugin 'quickly navigate configured project paths'

: "${BASH_IT_PROJECT_PATHS:=$HOME/Projects:$HOME/src:$HOME/work}"

function pj() {
	about 'navigate quickly to your various project directories'
	group 'projects'

	local proj="${1?${FUNCNAME[0]}: project name required}"
	local cmd PS3 dest
	local -a dests=()

	if [[ "$proj" == "open" ]]; then
		shift
		cmd="${EDITOR?}"
	fi

	# collect possible destinations to account for directories
	# with the same name in project directories
	IFS=':' read -ra dests <<< "${BASH_IT_PROJECT_PATHS}"

	# when multiple destinations are found, present a menu
	if [[ ${#dests[@]} -eq 0 ]]; then
		_log_error "no such project '${1:-}'"
		return 1
	elif [[ ${#dests[@]} -eq 1 ]]; then
		dest="${dests[0]}"
	elif [[ ${#dests[@]} -gt 1 ]]; then
		PS3="Multiple project directories found. Please select one: "
		dests+=("cancel")
		select d in "${dests[@]}"; do
			case $d in
				"cancel")
					return
					;;
				*)
					dest=$d
					break
					;;
			esac
		done
	else
		_log_error "please report this error"
		return 2 # should never reach this
	fi

	"${cmd:-cd}" "${dest}"
}

alias pjo="pj open"
