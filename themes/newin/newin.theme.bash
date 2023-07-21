#!/usr/bin/env bash

SCM_THEME_PROMPT_DIRTY=" ${red}✗"
SCM_THEME_PROMPT_CLEAN=" ${green}✓"
SCM_THEME_PROMPT_PREFIX=" ${purple}|${green} "
SCM_THEME_PROMPT_SUFFIX="${purple} |"

function prompt() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
    exit_code=$?
    PS1="$(if [[ ${exit_code} = 0 ]] 
     then echo "${green}${exit_code}"; else echo "${red}${exit_code}"; fi) ${yellow}\t ${cyan}\w$(scm_prompt_info)${reset_color}\n${orange}$ ${reset_color}"

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


safe_append_prompt_command prompt
