# shellcheck shell=bash
#
# Functions for working with Bash's command history.

function _bash-it-history-init() {
	safe_append_preexec '_bash-it-history-auto-save'
	safe_append_prompt_command '_bash-it-history-auto-load'
}

function _bash-it-history-auto-save() {
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
}

function _bash-it-history-auto-load() {
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
}

_bash_it_library_finalize_hook+=('_bash-it-history-init')
