# shellcheck shell=bash
#
# Displays the prompt from each _Bash It_ theme.

function _bash-it-preview() {
	local BASH_IT_THEME BASH_IT_LOG_LEVEL
	local themes IFS=$'\n' cur

	if [[ $# -gt '0' ]]; then
		themes=("$@")
	else
		themes=("${BASH_IT?}/themes"/*/*.theme.bash)
		themes=("${themes[@]##*/}")
		themes=("${themes[@]%.theme.bash}")
	fi

	if [[ ${COMP_CWORD:-} -gt '0' ]]; then
		cur="${COMP_WORDS[COMP_CWORD]}"
		read -d '' -ra COMPREPLY < <(compgen -W "all${IFS}${themes[*]}" -- "${cur}")
		return
	fi
	printf '\n\n\t%s\n\n' "Previewing Bash-it Themes"

	# shellcheck disable=SC2034
	for BASH_IT_THEME in "${themes[@]}"; do
		BASH_IT_LOG_LEVEL=0
		bash --init-file "${BASH_IT?}/bash_it.sh" -i <<< '_bash-it-flash-term "${#BASH_IT_THEME}" "${BASH_IT_THEME}"'
	done
}

if [[ -n "${BASH_PREVIEW:-}" ]]; then
	_bash-it-preview "${BASH_PREVIEW}" "$@"
	unset BASH_PREVIEW #Prevent infinite looping
fi
