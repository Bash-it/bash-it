# shellcheck shell=bash
#
# A collection of reusable functions.

###########################################################################
# Generic utilies
###########################################################################

function _bash-it-get-component-name-from-path() {
	local filename
	# filename without path
	filename="${1##*/}"
	# filename without path or priority
	filename="${filename##*"${BASH_IT_LOAD_PRIORITY_SEPARATOR?}"}"
	# filename without path, priority or extension
	echo "${filename%.*.bash}"
}

function _bash-it-get-component-type-from-path() {
	local filename
	# filename without path
	filename="${1##*/}"
	# filename without extension
	filename="${filename%.bash}"
	# extension without priority or name
	filename="${filename##*.}"
	echo "${filename}"
}

# This function searches an array for an exact match against the term passed
# as the first argument to the function. This function exits as soon as
# a match is found.
#
# Returns:
#   0 when a match is found, otherwise 1.
#
# Examples:
#   $ declare -a fruits=(apple orange pear mandarin)
#
#   $ _bash-it-array-contains-element apple "@{fruits[@]}" && echo 'contains apple'
#   contains apple
#
#   $ if _bash-it-array-contains-element pear "${fruits[@]}"; then
#       echo "contains pear!"
#     fi
#   contains pear!
#
#
function _bash-it-array-contains-element() {
	local e element="${1?}"
	shift
	for e in "$@"; do
		[[ "$e" == "${element}" ]] && return 0
	done
	return 1
}

# Dedupe an array (without embedded newlines).
function _bash-it-array-dedup() {
	printf '%s\n' "$@" | sort -u
}

# Runs `grep` with *just* the provided arguments
function _bash-it-grep() {
	: "${BASH_IT_GREP:=$(type -P grep)}"
	"${BASH_IT_GREP:-/usr/bin/grep}" "$@"
}

# Runs `grep` with fixed-string expressions (-F)
function _bash-it-fgrep() {
	: "${BASH_IT_GREP:=$(type -P grep)}"
	"${BASH_IT_GREP:-/usr/bin/grep}" -F "$@"
}

# Runs `grep` with extended regular expressions (-E)
function _bash-it-egrep() {
	: "${BASH_IT_GREP:=$(type -P grep)}"
	"${BASH_IT_GREP:-/usr/bin/grep}" -E "$@"
}

function _command_exists() {
	: _about 'checks for existence of a command'
	: _param '1: command to check'
	: _example '$ _command_exists ls && echo exists'
	: _group 'lib'

	type -t "${1?}" > /dev/null
}

function _binary_exists() {
	: _about 'checks for existence of a binary'
	: _param '1: binary to check'
	: _example '$ _binary_exists ls && echo exists'
	: _group 'lib'

	type -P "${1?}" > /dev/null
}

function _completion_exists() {
	: _about 'checks for existence of a completion'
	: _param '1: command to check'
	: _example '$ _completion_exists gh && echo exists'
	: _group 'lib'

	complete -p "${1?}" &> /dev/null
}

function _is_function() {
	: _about 'sets $? to true if parameter is the name of a function'
	: _param '1: name of alleged function'
	: _example '$ _is_function ls && echo exists'
	: _group 'lib'

	declare -F "${1?}" > /dev/null
}

###########################################################################
# Component-specific functions (component is either an alias, a plugin, or a
# completion).
###########################################################################

function _bash-it-component-help() {
	local component file func
	_bash-it-component-pluralize "${1}" component
	_bash-it-component-cache-file "${component}" file
	if [[ ! -s "${file?}" || -z "$(find "${file}" -mmin -300)" ]]; then
		func="_bash-it-${component?}"
		"${func}" | _bash-it-egrep '\[[x ]\]' >| "${file}"
	fi
	cat "${file}"
}

function _bash-it-component-cache-file() {
	local _component_to_cache _file_path _result="${2:-${FUNCNAME[0]//-/_}}"
	_bash-it-component-pluralize "${1?${FUNCNAME[0]}: component name required}" _component_to_cache
	_file_path="${XDG_CACHE_HOME:-${HOME?}/.cache}/bash/${_component_to_cache?}"
	[[ -f "${_file_path}" ]] || mkdir -p "${_file_path%/*}"
	printf -v "${_result?}" '%s' "${_file_path}"
}

function _bash-it-component-singularize() {
	local _result="${2:-${FUNCNAME[0]//-/_}}"
	local _component_to_single="${1?${FUNCNAME[0]}: component name required}"
	local -i len="$((${#_component_to_single} - 2))"
	if [[ "${_component_to_single:${len}:2}" == 'ns' ]]; then
		_component_to_single="${_component_to_single%s}"
	elif [[ "${_component_to_single}" == "aliases" ]]; then
		_component_to_single="${_component_to_single%es}"
	fi
	printf -v "${_result?}" '%s' "${_component_to_single}"
}

function _bash-it-component-pluralize() {
	local _result="${2:-${FUNCNAME[0]//-/_}}"
	local _component_to_plural="${1?${FUNCNAME[0]}: component name required}"
	local -i len="$((${#_component_to_plural} - 1))"
	# pluralize component name for consistency
	if [[ "${_component_to_plural:${len}:1}" != 's' ]]; then
		_component_to_plural="${_component_to_plural}s"
	elif [[ "${_component_to_plural}" == "alias" ]]; then
		_component_to_plural="${_component_to_plural}es"
	fi
	printf -v "${_result?}" '%s' "${_component_to_plural}"
}

function _bash-it-component-cache-clean() {
	local component="${1:-}"
	local cache
	local -a components=('aliases' 'plugins' 'completions')
	if [[ -z "${component}" ]]; then
		for component in "${components[@]}"; do
			_bash-it-component-cache-clean "${component}"
		done
	else
		_bash-it-component-cache-file "${component}" cache
		: >| "${cache:?}"
	fi
}

# Returns an array of items within each compoenent.
function _bash-it-component-list() {
	local IFS=$'\n' component="$1"
	_bash-it-component-help "${component}" | awk '{print $1}' | sort -u
}

function _bash-it-component-list-matching() {
	local component="$1"
	shift
	local term="$1"
	_bash-it-component-help "${component}" | _bash-it-egrep -- "${term}" | awk '{print $1}' | sort -u
}

function _bash-it-component-list-enabled() {
	local IFS=$'\n' component="$1"
	_bash-it-component-help "${component}" | _bash-it-fgrep '[x]' | awk '{print $1}' | sort -u
}

function _bash-it-component-list-disabled() {
	local IFS=$'\n' component="$1"
	_bash-it-component-help "${component}" | _bash-it-fgrep -v '[x]' | awk '{print $1}' | sort -u
}

# Checks if a given item is enabled for a particular component/file-type.
#
# Returns:
#    0 if an item of the component is enabled, 1 otherwise.
#
# Examples:
#    _bash-it-component-item-is-enabled alias git && echo "git alias is enabled"
function _bash-it-component-item-is-enabled() {
	local component_type item_name each_file

	if [[ -f "${1?}" ]]; then
		item_name="$(_bash-it-get-component-name-from-path "${1}")"
		component_type="$(_bash-it-get-component-type-from-path "${1}")"
	else
		component_type="${1}" item_name="${2?}"
	fi

	for each_file in "${BASH_IT?}/enabled"/*"${BASH_IT_LOAD_PRIORITY_SEPARATOR?}${item_name}.${component_type}"*."bash" \
		"${BASH_IT}/${component_type}"*/"enabled/${item_name}.${component_type}"*."bash" \
		"${BASH_IT}/${component_type}"*/"enabled"/*"${BASH_IT_LOAD_PRIORITY_SEPARATOR?}${item_name}.${component_type}"*."bash"; do
		if [[ -f "${each_file}" ]]; then
			return 0
		fi
	done

	return 1
}

# Checks if a given item is disabled for a particular component/file-type.
#
# Returns:
#    0 if an item of the component is enabled, 1 otherwise.
#
# Examples:
#    _bash-it-component-item-is-disabled alias git && echo "git aliases are disabled"
function _bash-it-component-item-is-disabled() {
	! _bash-it-component-item-is-enabled "$@"
}
