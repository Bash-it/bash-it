# shellcheck shell=bash

# colored ls
export LSCOLORS='Gxfxcxdxdxegedabagacad'

: "${CUSTOM_THEME_DIR:="${BASH_IT_CUSTOM:=${BASH_IT}/custom}/themes"}"

# Load the theme
# shellcheck disable=SC1090
if [[ -n "${BASH_IT_THEME:-}" ]]; then
	if [[ -f "${BASH_IT_THEME}" ]]; then
		source "${BASH_IT_THEME}"
	elif [[ -f "$CUSTOM_THEME_DIR/$BASH_IT_THEME/$BASH_IT_THEME.theme.bash" ]]; then
		source "$CUSTOM_THEME_DIR/$BASH_IT_THEME/$BASH_IT_THEME.theme.bash"
	else
		source "$BASH_IT/themes/$BASH_IT_THEME/$BASH_IT_THEME.theme.bash"
	fi
fi
