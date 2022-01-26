#!/usr/bin/env bash

SCM_THEME_PROMPT_DIRTY=" ${bold_yellow}✗"
SCM_THEME_PROMPT_CLEAN=" ${bold_green}✓"
SCM_THEME_PROMPT_PREFIX=" ${bold_blue}scm:("
SCM_THEME_PROMPT_SUFFIX="${bold_blue})"

GIT_THEME_PROMPT_DIRTY=" ${bold_yellow}✗"
GIT_THEME_PROMPT_CLEAN=" ${bold_green}✓"
GIT_THEME_PROMPT_PREFIX=" ${bold_blue}git:("
GIT_THEME_PROMPT_SUFFIX="${bold_blue})"

RVM_THEME_PROMPT_PREFIX="|"
RVM_THEME_PROMPT_SUFFIX="|"

function git_prompt_info() {
  git_prompt_vars
  echo -e "$SCM_PREFIX${bold_red}$SCM_BRANCH$SCM_STATE$SCM_SUFFIX"
}

function venv_parenthases() {
	if [[ $(venv_prompt) != "" ]]; then
		echo "($(venv_prompt)) "
	fi
}

function prompt_command() {
  PS1="$(venv_parenthases)${bold_green}➜  ${bold_cyan}\W${reset_color}$(scm_prompt_info)${normal} "
}

PROMPT_COMMAND=prompt_command
