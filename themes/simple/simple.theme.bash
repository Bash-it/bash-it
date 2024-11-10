#!/usr/bin/env bash

# prompt themeing

#added TITLEBAR for updating the tab and window titles with the pwd
case $TERM in
	xterm*)
		TITLEBAR="\[\033]0;\w\007\]"
		;;
	*)
		TITLEBAR=""
		;;
esac

function prompt_command() {
	PS1="${TITLEBAR}${orange}${reset_color}${green}\w${bold_blue}\[$(scm_prompt_info)\]${normal} "
}

# scm themeing
SCM_THEME_PROMPT_DIRTY=" ✗"
SCM_THEME_PROMPT_CLEAN=" ✓"
SCM_THEME_PROMPT_PREFIX="("
SCM_THEME_PROMPT_SUFFIX=")"

safe_append_prompt_command prompt_command
