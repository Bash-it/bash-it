# shellcheck shell=bash
# shellcheck disable=SC2034 # Expected behavior for themes.
# shellcheck disable=SC2154 #TODO: fix these all.

function prompt_command() {
	PS1="${green}\u@\h $(clock_prompt) ${reset_color}${white}\w${reset_color}$(scm_prompt_info)${blue} →${bold_blue} ${reset_color} ${normal}"
}

THEME_CLOCK_COLOR=${THEME_CLOCK_COLOR:-"$blue"}
THEME_CLOCK_FORMAT=${THEME_CLOCK_FORMAT:-"%I:%M:%S"}

safe_append_prompt_command prompt_command
