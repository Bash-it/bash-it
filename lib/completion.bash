# shellcheck shell=bash
# Functions for working with _Bash_'s Programmable Completion

#
##
# Testing Completion Functions
##
#

#

#
##
# Generating Completion Results
##
#

#

#
##
# Loading _Bash It_'s Completion Plugins
##

function _bash-it-completion-helper-necessary() {
	local requirement _result=0
	for requirement in "$@"; do
		if ! _binary_exists "${requirement}"; then
			_result=1
		fi
	done
	if [[ ${_result} -gt 0 ]]; then
		_log_warning "Without '${!#}' installed, this completion won't be too useful."
	fi
	return "${_result}"
}

function _bash-it-completion-helper-sufficient() {
	local completion _result=0
	for completion in "$@"; do
		if _completion_exists "${completion}"; then
			_result=1
		fi
	done
	if [[ ${_result} -gt 0 ]]; then
		_log_warning "completion already loaded - this usually means it is safe to stop using this completion."
	fi
	return "${_result}"
}
