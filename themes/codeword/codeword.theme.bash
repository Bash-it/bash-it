# shellcheck shell=bash
# shellcheck disable=SC2034 # Expected behavior for themes.

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

SCM_THEME_PROMPT_PREFIX="${SCM_THEME_PROMPT_SUFFIX:-}"
SCM_THEME_PROMPT_DIRTY="${bold_red?} ✗${normal?}"
SCM_THEME_PROMPT_CLEAN="${bold_green?} ✓${normal?}"
SCM_GIT_CHAR="${green?}±${normal?}"

function mark_prompt() {
	echo "${green?}\$${normal?}"
}

function user_host_path_prompt() {
	ps_user="${green?}\u${normal?}"
	ps_host="${blue?}\H${normal?}"
	ps_path="${yellow?}\w${normal?}"
	echo "${ps_user?}@${ps_host?}:${ps_path?}"
}

function prompt() {
	local SCM_PROMPT_FORMAT=' [%s%s]'
	PS1="$(user_host_path_prompt)$(virtualenv_prompt)$(scm_prompt) $(mark_prompt) "
}

safe_append_prompt_command prompt
