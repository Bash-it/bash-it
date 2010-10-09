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
PROMPT="${TITLEBAR}${orange}${reset_color}${green}\w${bold_blue}\[\$(git_prompt_info)\]${reset_color} "


# git themeing
# GIT_THEME_PROMPT_DIRTY=" ${red}✗"
# GIT_THEME_PROMPT_CLEAN=" ${bold_green}✓"
# GIT_THEME_PROMPT_PREFIX=" ${green}|"
# GIT_THEME_PROMPT_SUFFIX="${green}|"

GIT_THEME_PROMPT_DIRTY=" ✗"
GIT_THEME_PROMPT_CLEAN=" ✓"
GIT_THEME_PROMPT_PREFIX="("
GIT_THEME_PROMPT_SUFFIX=")"
