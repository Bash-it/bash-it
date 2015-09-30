#!/usr/bin/env bash
SCM_THEME_PROMPT_DIRTY=" ${red}✗"
SCM_THEME_PROMPT_CLEAN=" ${bold_green}✓"
SCM_THEME_PROMPT_PREFIX=" |"
SCM_THEME_PROMPT_SUFFIX="${green}|"

GIT_THEME_PROMPT_DIRTY=" ${red}✗"
GIT_THEME_PROMPT_CLEAN=" ${bold_green}✓"
GIT_THEME_PROMPT_PREFIX=" ${green}|"
GIT_THEME_PROMPT_SUFFIX="${green}|"

SCM_GIT_UNTRACKED_CHAR="${orange}?:"
SCM_GIT_UNSTAGED_CHAR="${red}U:"
SCM_GIT_STAGED_CHAR="${green}S:"

RVM_THEME_PROMPT_PREFIX="|"
RVM_THEME_PROMPT_SUFFIX="|"

function prompt_command() {
    PS1="${purple}\u${cyan}@${purple}\h${bold_purple} \n${yellow}$(ruby_version_prompt) ${bold_cyan}\w${green}$(scm_prompt_info) ${bold_green}\$${reset_color}"
}

PROMPT_COMMAND=prompt_command;
