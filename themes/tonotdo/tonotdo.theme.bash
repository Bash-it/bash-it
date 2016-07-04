#!/usr/bin/env bash

SCM_THEME_PROMPT_PREFIX=" ${purple}"
SCM_THEME_PROMPT_SUFFIX=" ${normal}"
SCM_THEME_PROMPT_DIRTY=" ${red}✗"
SCM_THEME_PROMPT_CLEAN=" ${green}✓"
SCM_GIT_SHOW_DETAILS="false"

function prompt_command() {
  PS1="${yellow}\u${normal}${cyan}@\h${normal}${purple} ${normal}${green}\w${normal}$(scm_prompt_info)> "
}

PROMPT_COMMAND=prompt_command
