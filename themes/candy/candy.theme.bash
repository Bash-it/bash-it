# shellcheck shell=bash
# shellcheck disable=SC2034 # Expected behavior for themes.

function prompt_command() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	local clock_prompt scm_prompt_info
	clock_prompt="$(clock_prompt)"
	scm_prompt_info="$(scm_prompt_info)"
	PS1="${green?}\u@\h ${clock_prompt} ${reset_color?}${white?}\w${reset_color?}${scm_prompt_info}${blue?} →${bold_blue?} ${reset_color?} ${normal?}"

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}

: "${THEME_CLOCK_COLOR:=${blue?}}"
: "${THEME_CLOCK_FORMAT:="%I:%M:%S"}"

safe_append_prompt_command prompt_command
