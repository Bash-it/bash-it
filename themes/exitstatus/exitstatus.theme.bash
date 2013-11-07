#!/usr/bin/env bash
SCM_THEME_PROMPT_DIRTY=""
SCM_THEME_PROMPT_CLEAN=""
SCM_THEME_PROMPT_PREFIX=""
SCM_THEME_PROMPT_SUFFIX=""

SUCCESS_PROMPT="${bold_green}→"
ERROR_PROMPT="${bold_red}✗"

git_prompt_status() {
  local git_status_output="$(git status 2> /dev/null)"

	if [ -n "$(echo $git_status_output | grep 'Changes not staged')" ]; then
		echo " [${bold_red}$(scm_prompt_info)${normal}]"
	elif [ -n "$(echo $git_status_output | grep 'Changes to be committed')" ]; then
		echo " [${bold_yellow}$(scm_prompt_info)${normal}]"
	elif [ -n "$(echo $git_status_output | grep 'Your branch is ahead')" ]; then
		echo " [${bold_blue}$(scm_prompt_info)${normal}]"
	elif [ -n "$(echo $git_status_output | grep 'Untracked files')" ]; then
		echo " [${bold_cyan}$(scm_prompt_info)${normal}]"
	elif [ -n "$(echo $git_status_output | grep 'nothing to commit')" ]; then
		echo " [${green}$(scm_prompt_info)${normal}]"
	fi
}

function prompt_command() {
	if [ $? = 0 ]; then RESULT_PROMPT=$SUCCESS_PROMPT; else RESULT_PROMPT=$ERROR_PROMPT; fi

	PS1="${bold_cyan}\u@\h ${bold_blue}\w${normal}$(git_prompt_status) $RESULT_PROMPT${normal} ";
}

PROMPT_COMMAND=prompt_command;
