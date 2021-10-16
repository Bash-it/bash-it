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
	[[ -t 1 && "${_bash_it_available_colors:=$(tput colors 2> /dev/null)}" -ge 8 ]]
}

function _bash-it-log-message() {
	about 'Internal function used for logging, uses BASH_IT_LOG_PREFIX as a prefix'
	param '1: color of the message'
	param '2: log level to print before the prefix'
	param '3: message to log'
	group 'log'

	message="$2${BASH_IT_LOG_PREFIX:-default: }$3"
	_has_colors && echo -e "$1${message}${echo_normal:-}" || echo -e "${message}"
}

function _log_debug() {
	about 'log a debug message by echoing to the screen. needs BASH_IT_LOG_LEVEL >= BASH_IT_LOG_LEVEL_INFO'
	param '1: message to log'
	example '$ _log_debug "Loading plugin git..."'
	group 'log'

	[[ "${BASH_IT_LOG_LEVEL:-0}" -ge "${BASH_IT_LOG_LEVEL_INFO?}" ]] || return 0
	_bash-it-log-message "${echo_green:-}" "DEBUG: " "$1"
}

function _log_warning() {
	about 'log a message by echoing to the screen. needs BASH_IT_LOG_LEVEL >= BASH_IT_LOG_LEVEL_WARNING'
	param '1: message to log'
	example '$ _log_warning "git binary not found, disabling git plugin..."'
	group 'log'

	[[ "${BASH_IT_LOG_LEVEL:-0}" -ge "${BASH_IT_LOG_LEVEL_WARNING?}" ]] || return 0
	_bash-it-log-message "${echo_yellow:-}" " WARN: " "$1"
}

function _log_error() {
	about 'log a message by echoing to the screen. needs BASH_IT_LOG_LEVEL >= BASH_IT_LOG_LEVEL_ERROR'
	param '1: message to log'
	example '$ _log_error "Failed to load git plugin..."'
	group 'log'

	[[ "${BASH_IT_LOG_LEVEL:-0}" -ge "${BASH_IT_LOG_LEVEL_ERROR?}" ]] || return 0
	_bash-it-log-message "${echo_red:-}" "ERROR: " "$1"
}
