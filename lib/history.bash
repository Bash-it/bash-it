# shellcheck shell=bash
#
# Functions for working with Bash's command history.

function _bash-it-history-init() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	safe_append_preexec '_bash-it-history-auto-save'
	safe_append_prompt_command '_bash-it-history-auto-load'
}

function _bash-it-history-auto-save() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	case $HISTCONTROL in
		*'noauto'* | *'autoload'*)
			: # Do nothing, as configured.
			;;
		*'auto'*)
			# Append new history from this session to the $HISTFILE
			history -a
			;;
		*)
			# Append *only* if shell option `histappend` has been enabled.
			shopt -q histappend && history -a && return
			;;
	esac
	
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}

function _bash-it-history-auto-load() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	case $HISTCONTROL in
		*'noauto'*)
			: # Do nothing, as configured.
			;;
		*'autosave'*)
			# Append new history from this session to the $HISTFILE
			history -a
			;;
		*'autoloadnew'*)
			# Read new entries from $HISTFILE
			history -n
			;;
		*'auto'*)
			# Blank in-memory history, then read entire $HISTFILE fresh from disk.
			history -a && history -c && history -r
			;;
		*)
			: # Do nothing, default.
			;;
	esac
	
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}

_bash_it_library_finalize_hook+=('_bash-it-history-init')
