#!/usr/bin/env bash

SCM_THEME_PROMPT_DIRTY=" ${red}✗"
SCM_THEME_PROMPT_CLEAN=" ${green}✓"
SCM_THEME_PROMPT_PREFIX=" ${blue}scm:( "
SCM_THEME_PROMPT_SUFFIX="${blue} )"

GIT_THEME_PROMPT_DIRTY=" ${red}✗"
GIT_THEME_PROMPT_CLEAN=" ${green}✓"
GIT_THEME_PROMPT_PREFIX="${green}git:( "
GIT_THEME_PROMPT_SUFFIX="${green} )"

function git_prompt_info {
  git_prompt_vars
  echo -e "$SCM_PREFIX$SCM_BRANCH$SCM_STATE$SCM_SUFFIX"
}

function prompt() {
  PS1="\h: \W $(scm_prompt_info)${reset_color} $ "
}

safe_append_prompt_command prompt
