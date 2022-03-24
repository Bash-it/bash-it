# shellcheck shell=bash
about-plugin 'quickly navigate configured project paths'

: "${BASH_IT_PROJECT_PATHS:=$HOME/Projects:$HOME/src:$HOME/work}"

function pj() {
	about 'navigate quickly to your various project directories'
	group 'projects'

	local proj="${1?${FUNCNAME[0]}: project name required}"
	local cmd PS3 dest d
	local -a dests

	if [[ "$proj" == "open" ]]; then
		shift
		proj="${1}"
		cmd="${EDITOR?}"
	fi

	# collect possible destinations to account for directories
	# with the same name in project directories
	IFS=':' read -ra dests <<< "${BASH_IT_PROJECT_PATHS?${FUNCNAME[0]}: project working folders must be configured}"
	for d in "${!dests[@]}"; do
		if [[ ! -d "${dests[d]}/${proj}" ]]; then
			unset 'dests[d]'
		fi
	done

	case ${#dests[@]} in
		0)
			_log_error "BASH_IT_PROJECT_PATHS must contain at least one existing location"
			return 1
			;;
		1)
			dest="${dests[*]}/${proj}"
			;;
		*)
			PS3="Multiple project directories found. Please select one: "
			dests+=("cancel")
			select d in "${dests[@]}"; do
				case $d in
					"cancel")
						return
						;;
					*)
						dest="${d}/${proj}"
						break
						;;
				esac
			done
			;;
	esac

	"${cmd:-cd}" "${dest}"
}

alias pjo="pj open"
