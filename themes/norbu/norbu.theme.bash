# shellcheck shell=bash
# shellcheck disable=SC2034 # Expected behavior for themes.

function set_prompt_symbol() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	if [[ $1 -eq 0 ]] 
     then
		prompt_symbol=">_"
	else
		prompt_symbol="${orange?}>_${normal?}"
	fi
}

function prompt_command() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	local ret_val="$?" prompt_symbol scm_prompt_info
	if [[ -n "${VIRTUAL_ENV:-}" ]] 
     then
		PYTHON_VIRTUALENV="${bold_yellow?}[${VIRTUAL_ENV##*/}]"
	fi

	scm_prompt_info="$(scm_prompt_info)"
	set_prompt_symbol "${ret_val}"
	PS1="${bold_orange?}${PYTHON_VIRTUALENV:-}${reset_color?}${bold_green?}[\w]${bold_blue?}[${scm_prompt_info}]${normal?} \n${prompt_symbol} "

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


# scm themeing
SCM_THEME_PROMPT_DIRTY=" ✗"
SCM_THEME_PROMPT_CLEAN=" ✓"
SCM_THEME_PROMPT_PREFIX="["
SCM_THEME_PROMPT_SUFFIX="]"

safe_append_prompt_command prompt_command
