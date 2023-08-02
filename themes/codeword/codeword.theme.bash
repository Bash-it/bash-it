# shellcheck shell=bash

SCM_THEME_PROMPT_PREFIX="${SCM_THEME_PROMPT_SUFFIX:-}"
SCM_THEME_PROMPT_DIRTY="${bold_red?} ✗${normal?}"
SCM_THEME_PROMPT_CLEAN="${bold_green?} ✓${normal?}"
SCM_GIT_CHAR="${green?}±${normal?}"

function mark_prompt() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
    echo "${green?}\$${normal?}"

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}

function user_host_path_prompt() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
    ps_user="${green?}\u${normal?}";
    ps_host="${blue?}\H${normal?}";
    ps_path="${yellow?}\w${normal?}";
    echo "${ps_user?}@${ps_host?}:${ps_path?}"

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
  local SCM_PROMPT_FORMAT=' [%s%s]'
  PS1="$(user_host_path_prompt)$(virtualenv_prompt)$(scm_prompt) $(mark_prompt) "

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}

safe_append_prompt_command '_save-and-reload-history 1'
safe_append_prompt_command prompt
