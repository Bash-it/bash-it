# shellcheck shell=bash
# shellcheck disable=SC2034 # Expected behavior for themes.
# shellcheck disable=SC2154 #TODO: fix these all.

SCM_THEME_PROMPT_PREFIX="${bold_green}[ ${normal}"
SCM_THEME_PROMPT_SUFFIX="${bold_green} ] "
SCM_THEME_PROMPT_DIRTY=" ${red}✗"
SCM_THEME_PROMPT_CLEAN=" ${bold_green}✓"

prompt_command() {
	if [ "$(whoami)" = root ]; then
		cursor_color="${bold_red}"
		user_color="${green}"
	else
		cursor_color="${bold_green}"
		user_color="${white}"
	fi
	PS1="${user_color}\u${normal}@${white}\h ${bold_black}\w\n${reset_color}$(scm_prompt_info)${cursor_color}❯ ${normal}"
}

safe_append_prompt_command prompt_command
