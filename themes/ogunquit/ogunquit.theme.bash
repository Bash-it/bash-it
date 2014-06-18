#!/usr/bin/env bash

# Copies the Bobby theme and then: a) colors command input differently (blue) from command output (white), by resetting 
# color immediately prior to command execution using preexec; b) replaces ruby prompt with virtualenv prompt

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

VIRTUALENV_THEME_PROMPT_PREFIX='[@env: '
VIRTUALENV_THEME_PROMPT_SUFFIX='] '

function prompt_command() {
    PS1="\n${yellow}$(virtualenv_prompt)${purple}\h ${reset_color}in ${green}\w\n${bold_cyan}$(scm_char)${green}$(scm_prompt_info) ${green}→${reset_color} \[$(tput setaf 4)\]"
}

PROMPT_COMMAND=prompt_command;

NOCOLOR="$(tput sgr0)"
function preexec () {
    tput sgr0
    #echo -ne "${NOCOLOR}"
}
preexec_install
