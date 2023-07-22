# shellcheck shell=bash

source "${BASH_IT}/themes/doubletime/doubletime.theme.bash"

function prompt_setter() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
  # Save history
  _save-and-reload-history 1
  PS1="
$(clock_prompt) $(scm_char) [$THEME_PROMPT_HOST_COLOR\u@${THEME_PROMPT_HOST}$reset_color] $(virtualenv_prompt)
\w
$(scm_prompt)$reset_color $ "
  PS2='> '
  PS4='+ '

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}

safe_append_prompt_command prompt_setter
