#!/usr/bin/env bash
SCM_THEME_PROMPT_DIRTY=" ${red}✗"
SCM_THEME_PROMPT_CLEAN=" ${bold_green}✓"
SCM_THEME_PROMPT_PREFIX=" |"
SCM_THEME_PROMPT_SUFFIX="${green}|"

GIT_THEME_PROMPT_DIRTY=" ${red}✗"
GIT_THEME_PROMPT_CLEAN=" ${bold_green}✓"
GIT_THEME_PROMPT_PREFIX=" ${green}|"
GIT_THEME_PROMPT_SUFFIX="${green}|"

RVM_THEME_PROMPT_PREFIX="|"
RVM_THEME_PROMPT_SUFFIX="|"

myip=`$BASH_IT/lib/get_ip.py`

function prompt_command() {
	PS1="${bold_cyan}\u${bold_red}@${bold_green}\H ${bold_yellow}($myip) ${bold_red}[\w] ${reset_color}\d \T\n${bold_cyan}$(scm_char)${green}$(scm_prompt_info) ${green}→${reset_color} "
}

PROMPT_COMMAND=prompt_command;
