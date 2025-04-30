# shellcheck shell=bash
# Ensure that we log to doctor so the user can address these issues
_is_function _init_completion \
	|| _log_error '_init_completion not found. Ensure bash-completion 2.0 or newer is installed and configured properly.'
_is_function _rl_enabled \
	|| _log_error '_rl_enabled not found. Ensure bash-completion 2.0 or newer is installed and configured properly.'

_pj() {
	_is_function _init_completion || return
	_is_function _rl_enabled || return
	[ -n "$BASH_IT_PROJECT_PATHS" ] || return
	shift
	[ "$1" == "open" ] && shift

	# shellcheck disable=SC2034
	local cur prev words cword # these are set by the call to _init_completion
	_init_completion || return

	local IFS=$'\n' i j k

	compopt -o filenames

	local -r mark_dirs=$(_rl_enabled mark-directories && echo y)
	local -r mark_symdirs=$(_rl_enabled mark-symlinked-directories && echo y)

	for i in ${BASH_IT_PROJECT_PATHS//:/$'\n'}; do
		# create an array of matched subdirs
		k="${#COMPREPLY[@]}"
		for j in $(compgen -d "$i/$cur"); do
			if [[ ($mark_symdirs && -L $j || $mark_dirs && ! -L $j) && ! -d ${j#"$i"/} ]]; then
				j+="/"
			fi
			COMPREPLY[k++]=${j#"$i"/}
		done
	done

	if [[ ${#COMPREPLY[@]} -eq 1 ]]; then
		i=${COMPREPLY[0]}
		if [[ "$i" == "$cur" && $i != "*/" ]]; then
			COMPREPLY[0]="${i}/"
		fi
	fi

	return 0
}

complete -F _pj -o nospace pj
complete -F _pj -o nospace pjo
