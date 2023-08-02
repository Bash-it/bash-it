# shellcheck shell=bash

function _user-prompt() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	local -r user='\u'

	if [[ "${EUID}" -eq 0 ]] 
     then
		# Privileged users:
		local -r user_color="${bold_red?}"
	else
		# Standard users:
		local -r user_color="${bold_green?}"
	fi

	# Print the current user's name (colored according to their current EUID):
	printf '%b%s%b' "${user_color}" "${user}" "${normal?}"

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}

function _host-prompt() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	local -r host='\h'

	# Check whether or not $SSH_TTY is set:
	if [[ -z "${SSH_TTY:-}" ]] 
     then
		# For local hosts, set the host's prompt color to blue:
		local -r host_color="${bold_blue?}"
	else
		# For remote hosts, set the host's prompt color to red:
		local -r host_color="${bold_red?}"
	fi

	# Print the current hostname (colored according to $SSH_TTY's status):
	printf '%b%s%b' "${host_color}" "${host}" "${normal?}"

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}

function _user-at-host-prompt() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	# Concatenate the user and host prompts into: user@host:
	_user-prompt
	printf '%b@' "${bold_white?}"
	_host-prompt

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}

function _exit-status-prompt() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	local -r prompt_string="${1}"
	local -r exit_status="${2}"

	# Check the exit status of the last command captured by $exit_status:
	if [[ "${exit_status}" -eq 0 ]] 
     then
		# For commands that return an exit status of zero, set the exit status's
		# notifier to green:
		local -r exit_status_color="${bold_green?}"
	else
		# For commands that return a non-zero exit status, set the exit status's
		# notifier to red:
		local -r exit_status_color="${bold_red?}"
	fi

	if [[ "${prompt_string}" -eq 1 ]] 
     then
		# $PS1:
		printf '%b +%b' "${exit_status_color}" "${normal?} "
	elif [[ "${prompt_string}" -eq 2 ]] 
     then
		# $PS2:
		printf '%b |%b' "${exit_status_color}" "${normal?} "
	else
		# Default:
		printf '%b ?%b' "${exit_status_color}" "${normal?} "
	fi

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}

function _ps1() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	local -r time='\t'
	local -r pwd='\w'

	printf '%b%s ' "${bold_white?}" "${time}"
	_user-at-host-prompt
	printf '%b:%b%s\n' "${bold_white?}" "${normal?}" "${pwd}"
	_exit-status-prompt 1 "${exit_status}"

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}

function _ps2() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	_exit-status-prompt 2 "${exit_status}"

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}

function prompt_command() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	# Capture the exit status of the last command:
	local -r exit_status="${?}"

	# Build the $PS1 prompt:
	PS1="$(_ps1)"

	# Build the $PS2 prompt:
	PS2="$(_ps2)"

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}

safe_append_prompt_command prompt_command
