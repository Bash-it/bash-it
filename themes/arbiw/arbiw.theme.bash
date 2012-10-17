#!/usr/bin/env bash
SCM_THEME_PROMPT_PREFIX=''
SCM_THEME_PROMPT_SUFFIX=''
function prompt_command() {
    PS1="${green}\u@\h ${cyan}[\t] ${reset_color}${white}[\w] ${orange}[$(scm_prompt_info)${orange}]\n ${reset_color}\$ ";
}

PROMPT_COMMAND=prompt_command;
