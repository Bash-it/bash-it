#!/usr/bin/env bash

SCM_THEME_PROMPT_DIRTY=" ${red}✗"
SCM_THEME_PROMPT_CLEAN=" ${bold_green}✓"
SCM_THEME_PROMPT_PREFIX=" ["
SCM_THEME_PROMPT_SUFFIX="${green}]"

GIT_THEME_PROMPT_DIRTY=" ${red}✗"
GIT_THEME_PROMPT_CLEAN=" ${bold_green}✓"
GIT_THEME_PROMPT_PREFIX=" ${green}["
GIT_THEME_PROMPT_SUFFIX="${green}]"

function prompt_command() {
    # PS1="${green}\u@\h ${blue}\T ${reset_color}${white}\w${reset_color}$(scm_prompt_info)${blue} →${bold_blue} ${reset_color} ";
    PS1="${bold_green}\u@\h ${bold_blue}[\T] ${reset_color}${white}[\w]${reset_color}$(scm_prompt_info)${blue}\n-> ${bold_blue}% ${reset_color}";
}

PROMPT_COMMAND=prompt_command;
