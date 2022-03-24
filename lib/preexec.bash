# shellcheck shell=bash
# shellcheck disable=SC2034
#
# Load the `bash-preexec.sh` library, and define helper functions

## Prepare, load, fix, and install `bash-preexec.sh`

# Disable `$PROMPT_COMMAND` modification for now.
__bp_delay_install="delayed"

# shellcheck source-path=SCRIPTDIR/../vendor/github.com/rcaloras/bash-preexec
source "${BASH_IT?}/vendor/github.com/rcaloras/bash-preexec/bash-preexec.sh"

# Block damanaging user's `$HISTCONTROL`
function __bp_adjust_histcontrol() { :; }

# Don't fail on readonly variables
function __bp_require_not_readonly() { :; }

# For performance, testing, and to avoid unexpected behavior: disable DEBUG traps in subshells.
# See bash-it/bash-it#1040 and rcaloras/bash-preexec#26
: "${__bp_enable_subshells:=}" # blank

# Modify `$PROMPT_COMMAND` in finalize hook
_bash_it_library_finalize_hook+=('__bp_install_after_session_init')

## Helper functions
function __check_precmd_conflict() {
	local f
	__bp_trim_whitespace f "${1?}"
	_bash-it-array-contains-element "${f}" "${precmd_functions[@]}"
}

function __check_preexec_conflict() {
	local f
	__bp_trim_whitespace f "${1?}"
	_bash-it-array-contains-element "${f}" "${preexec_functions[@]}"
}

function safe_append_prompt_command() {
	local prompt_re prompt_er f

	if [[ "${bash_preexec_imported:-${__bp_imported:-missing}}" == "defined" ]]; then
		# We are using bash-preexec
		__bp_trim_whitespace f "${1?}"
		if ! __check_precmd_conflict "${f}"; then
			precmd_functions+=("${f}")
		fi
	else
		# Match on word-boundaries
		prompt_re='(^|[^[:alnum:]_])'
		prompt_er='([^[:alnum:]_]|$)'
		if [[ ${PROMPT_COMMAND} =~ ${prompt_re}"${1}"${prompt_er} ]]; then
			return
		elif [[ -z ${PROMPT_COMMAND} ]]; then
			PROMPT_COMMAND="${1}"
		else
			PROMPT_COMMAND="${1};${PROMPT_COMMAND}"
		fi
	fi
}

function safe_append_preexec() {
	local prompt_re f

	if [[ "${bash_preexec_imported:-${__bp_imported:-missing}}" == "defined" ]]; then
		# We are using bash-preexec
		__bp_trim_whitespace f "${1?}"
		if ! __check_preexec_conflict "${f}"; then
			preexec_functions+=("${f}")
		fi
	else
		_log_error "${FUNCNAME[0]}: can't append to preexec hook because _bash-preexec.sh_ hasn't been loaded"
	fi
}
