#!/usr/bin/env bash

SCM_THEME_PROMPT_DIRTY=" ${red}✗"
SCM_THEME_PROMPT_CLEAN=" ${bold_green}✓"
SCM_THEME_PROMPT_PREFIX=" |"
SCM_THEME_PROMPT_SUFFIX="${green}|"

GIT_THEME_PROMPT_DIRTY=" ${red}✗"
GIT_THEME_PROMPT_CLEAN=" ${bold_green}✓"
GIT_THEME_PROMPT_PREFIX="${yellow}"
GIT_THEME_PROMPT_SUFFIX="${yellow} "

function echoer() {
PS1="$(scm_prompt_info)${cyan} \w ${green}➤ ${reset_color} "
}

PROMPT_COMMAND=echoer; 

#→ 
