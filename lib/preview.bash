# shellcheck shell=bash
#
# Displays the prompt from each _Bash It_ theme.

function _bash-it-preview() {
	local BASH_IT_THEME BASH_IT_LOG_LEVEL
	local themes theme

	printf '\n\n\t%s\n\n' "Previewing Bash-it Themes"

	if [[ -n "${1:-}" && -s "${BASH_IT?}/themes/${1}/${1}.theme.bash" ]]; then
		themes=("${1}")
	else
		themes=("${BASH_IT?}/themes"/*/*.theme.bash)
	fi

	# shellcheck disable=SC2034
	for theme in "${themes[@]}"; do
		BASH_IT_THEME="${theme%.theme.bash}"
		BASH_IT_THEME="${BASH_IT_THEME##*/}"
		BASH_IT_LOG_LEVEL=0

		bash --init-file "${BASH_IT_BASHRC:-${BASH_IT?}/bash_it.sh}" -i <<< '_bash-it-flash-term "${#BASH_IT_THEME}" "${BASH_IT_THEME}"'
	done
}

if [[ -n "${BASH_PREVIEW:-}" ]]; then
	_bash-it-preview "${BASH_PREVIEW}" "$@"
	unset BASH_PREVIEW #Prevent infinite looping
fi
