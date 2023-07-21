#!/usr/bin/env bash

SCM_THEME_PROMPT_PREFIX="${cyan} on ${green}"
SCM_THEME_PROMPT_SUFFIX=""
SCM_THEME_PROMPT_DIRTY=" ${red}with changes"
SCM_THEME_PROMPT_CLEAN=""

function venv() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
  if [ ! -z "$VIRTUAL_ENV" ]
  then
    local env=$VIRTUAL_ENV
    echo "${gray} in ${orange}${env##*/} "
  fi

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}

function last_two_dirs() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
  pwd|rev|awk -F / '{print $1,$2}'|rev|sed s_\ _/_|sed "s|$(sed 's,\/,,'<<<$HOME)|~|g"

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}

function prompt() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
  PS1="${yellow}# ${reset_color}$(last_two_dirs)$(scm_prompt_info)${reset_color}$(venv)${reset_color} ${cyan}\n> ${reset_color}"

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}

safe_append_prompt_command prompt
