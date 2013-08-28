#!/usr/bin/env bash
SCM_NONE_CHAR=''
SCM_THEME_PROMPT_DIRTY=" ${red}✗${reset_color}"
SCM_THEME_PROMPT_CLEAN=" ${bold_green}✓${reset_color}"
SCM_THEME_PROMPT_PREFIX=" ${reset_color}|$(scm_char) "
SCM_THEME_PROMPT_SUFFIX="${reset_color}|${reset_color}"


RVM_THEME_PROMPT_PREFIX="|"
RVM_THEME_PROMPT_SUFFIX="|"

function prompt_command() {
    #PS1="${bold_cyan}$(scm_char)${green}$(scm_prompt_info)${purple}$(ruby_version_prompt) ${yellow}\h ${reset_color}in ${green}\w ${reset_color}\n${green}→${reset_color} "
    PS1="${yellow}$(ruby_version_prompt) ${purple}\u@\h${reset_color}:\W${bold_cyan}${green}$(scm_prompt_info)${reset_color}${reset_color}\$ "
}

PROMPT_COMMAND=prompt_command;
