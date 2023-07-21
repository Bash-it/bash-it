#!/usr/bin/env bash

# based of the candy theme, but minimized by odbol
function prompt_command() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
    PS1="$(clock_prompt) ${reset_color}${white}\w${reset_color}$(scm_prompt_info)${blue} →${bold_blue} ${reset_color} ";

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}



THEME_CLOCK_COLOR=${THEME_CLOCK_COLOR:-"$blue"}
THEME_CLOCK_FORMAT=${THEME_CLOCK_FORMAT:-"%I:%M:%S"}

safe_append_prompt_command prompt_command
