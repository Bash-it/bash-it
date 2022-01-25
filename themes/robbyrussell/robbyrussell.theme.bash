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

function venv_prompt() {
	python_venv=""
	# Detect python venv
	if [[ -n "${CONDA_DEFAULT_ENV}" ]]; then
		python_venv="($PYTHON_VENV_CHAR${CONDA_DEFAULT_ENV}) "
	elif [[ -n "${VIRTUAL_ENV}" ]]; then
		python_venv="($PYTHON_VENV_CHAR$(basename "${VIRTUAL_ENV}")) "
	fi
	[[ -n "${python_venv}" ]] && echo "${python_venv}"
}

function prompt_command() {
  PS1="$(venv_prompt)${bold_green}➜  ${bold_cyan}\W${reset_color}$(scm_prompt_info)${normal} "
}

PROMPT_COMMAND=prompt_command
