# shellcheck shell=bash
# shellcheck disable=SC2034 # Expected behavior for themes.

SCM_THEME_PROMPT_PREFIX="${cyan?}(${green?}"
SCM_THEME_PROMPT_SUFFIX="${cyan?})"
SCM_THEME_PROMPT_DIRTY=" ${red?}✗"
SCM_THEME_PROMPT_CLEAN=" ${green?}✓"

prompt() {
	PS1="$(scm_prompt_info)${reset_color?} ${cyan?}\W${reset_color?} "
}

safe_append_prompt_command prompt
