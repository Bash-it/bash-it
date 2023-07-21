#!/usr/bin/env bash

SCM_THEME_PROMPT_PREFIX=" ${purple}"
SCM_THEME_PROMPT_SUFFIX=" ${normal}"
SCM_THEME_PROMPT_DIRTY=" ${red}✗"
SCM_THEME_PROMPT_CLEAN=" ${green}✓"
SCM_GIT_SHOW_DETAILS="false"

function prompt_command() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
  PS1="${yellow}\u${normal}${cyan}@\h${normal}${purple} ${normal}${green}\w${normal}$(scm_prompt_info)> "

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


safe_append_prompt_command prompt_command
