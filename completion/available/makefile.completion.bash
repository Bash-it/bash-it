# shellcheck shell=bash

# Bash completion for Makefile
# Loosely adapted from http://stackoverflow.com/a/38415982/1472048

_makecomplete() {
	COMPREPLY=()

	# https://www.gnu.org/software/make/manual/html_node/Makefile-Names.html
	local files=()
	for f in 'GNUmakefile' 'makefile' 'Makefile'; do
		[ -f "$f" ] && files+=("$f")
	done

	[ "${#files[@]}" -eq 0 ] && return 0

	# collect all targets
	local targets=()
	for f in "${files[@]}"; do
		while IFS='' read -r line; do
			targets+=("$line")
		done < <(grep -E -o '^[a-zA-Z0-9_-]+:([^=]|$)' "$f" | cut -d':' -f1)
	done

	[ "${#targets[@]}" -eq 0 ] && return 0

	# use the targets for completion
	while IFS='' read -r line; do
		COMPREPLY+=("$line")
	done < <(compgen -W "$(tr ' ' '\n' <<< "${targets[@]}" | sort -u)" -- "${COMP_WORDS[COMP_CWORD]}")

	return 0
}

complete -o nospace -F _makecomplete make
complete -o nospace -F _makecomplete gnumake
