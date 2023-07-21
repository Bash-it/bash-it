# shellcheck shell=bash
cite about-plugin
about-plugin 'Alert (BEL) when process ends after a threshold of seconds'

function precmd_return_notification() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	local command_start="${COMMAND_DURATION_START_SECONDS:=0}"
	local current_time
	current_time="$(_shell_duration_en)"
	local -i command_duration="$((${current_time%.*} - ${command_start%.*}))"
	if [[ "${command_duration}" -gt "${NOTIFY_IF_COMMAND_RETURNS_AFTER:-5}" ]] 
     then
		printf '\a'
	fi
	return 0
	
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}

safe_append_prompt_command 'precmd_return_notification'
safe_append_preexec '_command_duration_pre_exec'
