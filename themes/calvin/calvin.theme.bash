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

PROMPT_END_CLEAN="\$"
PROMPT_END_DIRTY="${red}\$${reset_color}"

function prompt_end(){
    echo -e "$PROMPT_END"
}

function prompt_command() {
    if [[ $? -eq 0 ]]; then PROMPT_END=$PROMPT_END_CLEAN
    else PROMPT_END=$PROMPT_END_DIRTY
    fi
    PS1="${yellow}$(ruby_version_prompt)${purple}\u@\h${reset_color}:\W${green}${bold_cyan}${green}$(scm_prompt_info) ${reset_color}$(prompt_end) "
}

PROMPT_COMMAND=prompt_command;