#!/usr/bin/env bash

GIT_THEME_PROMPT_DIRTY="${red}✗"
GIT_THEME_PROMPT_CLEAN="${bold_green}✓"
GIT_THEME_PROMPT_PREFIX="${bold_cyan}["
GIT_THEME_PROMPT_SUFFIX="${bold_cyan}]"

VIRTUALENV_THEME_PROMPT_PREFIX="${bold_green}["
VIRTUALENV_THEME_PROMPT_SUFFIX="${bold_green}]"
CONDAENV_THEME_PROMPT_PREFIX="${bold_green}["
CONDAENV_THEME_PROMPT_SUFFIX="${bold_green}]"
PYTHON_THEME_PROMPT_PREFIX="${bold_green}["
PYTHON_THEME_PROMPT_SUFFIX="${bold_green}]"

function prompt_command() {
	PS1="\n${bold_white}[\u@\h]${bold_yellow}[\w] ${bold_cyan}$(scm_prompt_char_info)$(python_version_prompt)${green}\n→${reset_color} "
}

safe_append_prompt_command prompt_command
