# shellcheck shell=bash
# shellcheck disable=SC2034 # Expected behavior for themes.

source "$BASH_IT/themes/doubletime/doubletime.theme.bash"

function prompt_setter() {
	# Save history
	_save-and-reload-history 1
	PS1="
$(clock_prompt) $(scm_char) [$THEME_PROMPT_HOST_COLOR\u@${THEME_PROMPT_HOST}${reset_color?}] $(virtualenv_prompt)
\w
$(scm_prompt)$reset_color $ "
	PS2='> '
	PS4='+ '
}

safe_append_prompt_command prompt_setter
