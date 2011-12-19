#!/bin/bash

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
PROMPT="${TITLEBAR}${bold_green}\w${reset_color}${bold_blue}\$(scm_prompt_info)${reset_color} "

# scm theming
SCM_THEME_PROMPT_PREFIX="("
SCM_THEME_PROMPT_SUFFIX=")"
