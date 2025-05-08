# shellcheck shell=bash
# shellcheck disable=SC2034 # Expected behavior for themes.

source "$BASH_IT/themes/doubletime/doubletime.theme.bash"

case $HISTCONTROL in
*'auto'*)
	: # Do nothing, already configured.
	;;
*)
	# Append new history lines to history file
	HISTCONTROL="${HISTCONTROL:-}${HISTCONTROL:+:}autosave"
	;;
esac
safe_append_preexec '_bash-it-history-auto-load'
safe_append_prompt_command '_bash-it-history-auto-save'

function prompt_setter() {
  PS1="
$(clock_prompt) $(scm_char) [$THEME_PROMPT_HOST_COLOR\u@${THEME_PROMPT_HOST}$reset_color?] $(virtualenv_prompt)$(ruby_version_prompt)
\w
$(scm_prompt)$reset_color $ "
	PS2='> '
	PS4='+ '
}

safe_append_prompt_command prompt_setter
