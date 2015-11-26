#!/usr/bin/env bash

light_blue="$(color reset blue)"
light_red="$(color reset red)"


SCM_THEME_PROMPT_DIRTY=" ${bold_red}✗"
SCM_THEME_PROMPT_CLEAN=" ${bold_green}✓"
SCM_THEME_PROMPT_PREFIX=" ${light_blue}scm:("
SCM_THEME_PROMPT_SUFFIX="${light_blue})"

GIT_THEME_PROMPT_DIRTY=" ${bold_red}✗"
GIT_THEME_PROMPT_CLEAN=" ${bold_green}✓"
GIT_THEME_PROMPT_PREFIX="${light_blue}git:("
GIT_THEME_PROMPT_SUFFIX="${light_blue})"

RVM_THEME_PROMPT_PREFIX="|"
RVM_THEME_PROMPT_SUFFIX="|"

function git_prompt_info {
  git_prompt_vars
  echo -e "$SCM_PREFIX$SCM_BRANCH$SCM_STATE$SCM_SUFFIX"
}

prompt() {
  PS1="\h: ${reset_color}${green}\W${reset_color} $(scm_prompt_info)${reset_color}${reset_color} $ "
}

PROMPT_COMMAND=prompt
