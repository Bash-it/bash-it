# shellcheck shell=bash
#
# A collection of logging functions.

# Declare log severity levels, matching syslog numbering
: "${BASH_IT_LOG_LEVEL_FATAL:=1}"
: "${BASH_IT_LOG_LEVEL_ERROR:=3}"
: "${BASH_IT_LOG_LEVEL_WARNING:=4}"
: "${BASH_IT_LOG_LEVEL_ALL:=6}"
: "${BASH_IT_LOG_LEVEL_INFO:=6}"
: "${BASH_IT_LOG_LEVEL_TRACE:=7}"
readonly "${!BASH_IT_LOG_LEVEL_@}"

function _bash-it-log-prefix-by-path() {
	local component_path="${1?${FUNCNAME[0]}: path specification required}"
	local without_extension component_directory
	local component_filename component_type component_name

	# get the directory, if any
	component_directory="${component_path%/*}"
	# drop the directory, if any
	component_filename="${component_path##*/}"
	# strip the file extension
	without_extension="${component_filename%.bash}"
	# strip before the last dot
	component_type="${without_extension##*.}"
	# strip component type, but try not to strip other words
	# - aliases, completions, plugins, themes
	component_name="${without_extension%.[acpt][hlo][eimu]*[ens]}"
	# Finally, strip load priority prefix
	component_name="${component_name##[[:digit:]][[:digit:]][[:digit:]]"${BASH_IT_LOAD_PRIORITY_SEPARATOR:----}"}"

	# best-guess for files without a type
	if [[ "${component_type:-${component_name}}" == "${component_name}" ]]; then
		if [[ "${component_directory}" == *'vendor'* ]]; then
			component_type='vendor'
		else
			component_type="${component_directory##*/}"
		fi
	fi

	# shellcheck disable=SC2034
	BASH_IT_LOG_PREFIX="${component_type:-lib}: $component_name"
}

function _has_colors() {
	# Check that stdout is a terminal, and that it has at least 8 colors.
	[[ -t 1 && "${CLICOLOR:=$(tput colors 2> /dev/null)}" -ge 8 ]]
}

function _bash-it-log-message() {
	: _about 'Internal function used for logging, uses BASH_IT_LOG_PREFIX as a prefix'
	: _param '1: color of the message'
	: _param '2: log level to print before the prefix'
	: _param '3: message to log'
	: _group 'log'

	local prefix="${BASH_IT_LOG_PREFIX:-default}"
	local color="${1-${echo_cyan:-}}"
	local level="${2:-TRACE}"
	local message="${level%: }: ${prefix%: }: ${3?}"
	if _has_colors; then
		printf '%b%s%b\n' "${color}" "${message}" "${echo_normal:-}"
	else
		printf '%s\n' "${message}"
	fi
}

function _log_debug() {
	: _about 'log a debug message by echoing to the screen. needs BASH_IT_LOG_LEVEL >= BASH_IT_LOG_LEVEL_INFO'
	: _param '1: message to log'
	: _example '$ _log_debug "Loading plugin git..."'
	: _group 'log'

	if [[ "${BASH_IT_LOG_LEVEL:-0}" -ge "${BASH_IT_LOG_LEVEL_INFO?}" ]]; then
		_bash-it-log-message "${echo_green:-}" "DEBUG: " "$1"
	fi
}

function _log_warning() {
	: _about 'log a message by echoing to the screen. needs BASH_IT_LOG_LEVEL >= BASH_IT_LOG_LEVEL_WARNING'
	: _param '1: message to log'
	: _example '$ _log_warning "git binary not found, disabling git plugin..."'
	: _group 'log'

	if [[ "${BASH_IT_LOG_LEVEL:-0}" -ge "${BASH_IT_LOG_LEVEL_WARNING?}" ]]; then
		_bash-it-log-message "${echo_yellow:-}" " WARN: " "$1"
	fi
}

function _log_error() {
	: _about 'log a message by echoing to the screen. needs BASH_IT_LOG_LEVEL >= BASH_IT_LOG_LEVEL_ERROR'
	: _param '1: message to log'
	: _example '$ _log_error "Failed to load git plugin..."'
	: _group 'log'

	if [[ "${BASH_IT_LOG_LEVEL:-0}" -ge "${BASH_IT_LOG_LEVEL_ERROR?}" ]]; then
		_bash-it-log-message "${echo_red:-}" "ERROR: " "$1"
	fi
}
