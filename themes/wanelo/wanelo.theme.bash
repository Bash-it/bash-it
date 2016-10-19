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

function prompt_command() {
    if [ $? -eq 0 ]; then
      status=❤️
    else
      status=💔
    fi
    PS1="\n${yellow}$(ruby_version_prompt) ${purple}\h ${reset_color}in ${green}\w $status \n${bold_cyan} ${blue}|$(clock_prompt)|${green}$(scm_prompt_info) ${green}→${reset_color} "
}

THEME_CLOCK_COLOR=${THEME_CLOCK_COLOR:-"$blue"}

PROMPT_COMMAND=prompt_command;
