#!/usr/bin/env bash
SCM_NONE_CHAR=''

SCM_THEME_PROMPT_DIRTY=" ${red}✗"
SCM_THEME_PROMPT_CLEAN=" ${bold_green}✓"
SCM_THEME_PROMPT_PREFIX=" |"
SCM_THEME_PROMPT_SUFFIX="${green}|"


GIT_THEME_PROMPT_DIRTY=" ${red}✗"
GIT_THEME_PROMPT_CLEAN=" ${bold_green}✓"
GIT_THEME_PROMPT_PREFIX=" ${green}|$(scm_char) "
GIT_THEME_PROMPT_SUFFIX="${green}|"

RVM_THEME_PROMPT_PREFIX="|"
RVM_THEME_PROMPT_SUFFIX="|"

PROMPT_CHAR_CLEAN="${reset_color}\$"
PROMPT_CHAR_DIRTY="${red}\$${reset_color}"

function prompt_char() {
    if [ $? -eq 0 ]; then PROMPT_CHAR=$PROMPT_CHAR_CLEAN
    else PROMPT_CHAR=$PROMPT_CHAR_DIRTY
    fi
    echo -e "$? \$"
}

function prompt_command() {

    PS1="${yellow}$(ruby_version_prompt)${purple}\u@\h${reset_color}:\W${green}${bold_cyan}${green}$(scm_prompt_info) ${green}${reset_color}$? \$ "

    #PS1="${yellow}$(ruby_version_prompt)${purple}\u@\h${reset_color}:\W${green}${bold_cyan}${green}$(scm_prompt_info) ${green}${reset_color}\$ "
}

PROMPT_COMMAND=prompt_command;