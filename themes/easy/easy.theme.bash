# shellcheck shell=bash
# shellcheck disable=SC2034 # Expected behavior for themes.

SCM_THEME_PROMPT_PREFIX="${bold_green?}[ ${normal?}"
SCM_THEME_PROMPT_SUFFIX="${bold_green?} ] "
SCM_THEME_PROMPT_DIRTY=" ${red?}✗"
SCM_THEME_PROMPT_CLEAN=" ${bold_green?}✓"

function prompt_command() {
	local scm_prompt_info
	if [ "${USER:-${LOGNAME?}}" = root ]; then
		cursor_color="${bold_red?}"
		user_color="${green?}"
	else
		cursor_color="${bold_green?}"
		user_color="${white?}"
	fi
	scm_prompt_info="$(scm_prompt_info)"
	PS1="${user_color}\u${normal?}@${white?}\h ${bold_black?}\w\n${reset_color?}${scm_prompt_info}${cursor_color}❯ ${normal?}"
}

safe_append_prompt_command prompt_command
