#!/bin/bash
#
# Based on 'bobby' theme with the addition of virtualenv_prompt
#

SCM_THEME_PROMPT_DIRTY=" ${red}✗"
SCM_THEME_PROMPT_CLEAN=" ${green}✓"
SCM_THEME_PROMPT_PREFIX=" ${yellow}|${reset_color}"
SCM_THEME_PROMPT_SUFFIX="${yellow}|"

RVM_THEME_PROMPT_PREFIX="|"
RVM_THEME_PROMPT_SUFFIX="|"
VIRTUALENV_THEME_PROMPT_PREFIX='|'
VIRTUALENV_THEME_PROMPT_SUFFIX='|'

function prompt_command() {
    PS1="\n${green}$(virtualenv_prompt)${red}$(rvm_version_prompt) ${reset_color}\h ${orange}in ${reset_color}\w\n${yellow}$(scm_char)$(scm_prompt_info) ${yellow}→${white} "
}

PROMPT_COMMAND=prompt_command;
