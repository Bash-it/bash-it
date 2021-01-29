# shellcheck shell=bash

BASH_IT_LOG_PREFIX="core: reloader: "
pushd "${BASH_IT}" > /dev/null || exit 1

_bash-it-load-sources() {
	if [[ -z "$1" ]]; then
		return 0
	fi

	local scripts current output retval

	scripts=("$@")
	current="${scripts[0]}"
	scripts=("${scripts[@]:1}")

	filename=$(_bash-it-get-component-name-from-path "$current")
	extension=$(_bash-it-get-component-type-from-path "$current")
	BASH_IT_LOG_PREFIX="$extension: $filename: "

	if [[ -e $current ]]; then

		_log_debug "Loading component..."
		output=$(
			set -e
			BASH_IT_LOG_PREFIX=""
			# shellcheck disable=SC1090
			(source "$current") 2>&1
			BASH_IT_LOG_PREFIX="$extension: $filename: "
		)
		retval=$?
		set +e

		trap '_bash-it-load-sources ${scripts[@]}' EXIT
		if [[ $retval -gt 0 ]]; then
			_log_error 'Loading component failed...'
			if [[ -n "$output" ]]; then
				while read -r line; do _log_error "$line"; done <<< "$output"
			fi
		else
			_log_debug 'Loading component successful!'
			# shellcheck disable=SC1090
			source "$current"
		fi
		trap - EXIT

	else
		_log_error "Unable to read $current"
	fi

	_bash-it-load-sources "${scripts[@]}"
}

if [[ "$1" != "skip" ]] && [[ -d "./enabled" ]]; then
	_bash_it_config_type=""

	# shellcheck disable=SC2221,SC2222
	case $1 in
		alias | completion | plugin)
			_bash_it_config_type=$1
			_log_debug "Loading enabled $1 components..."
			;;
		* | '')
			_log_debug "Loading all enabled components..."
			;;
	esac

	# shellcheck disable=SC2046
	_bash-it-load-sources $(sort <(compgen -G "./enabled/*${_bash_it_config_type}.bash"))
fi

if [[ -n "${2}" ]] && [[ -d "${2}/enabled" ]]; then
	case $2 in
		aliases | completion | plugins)
			_log_warning "Using legacy enabling for $2, please update your bash-it version and migrate"
			# shellcheck disable=SC2046
			_bash-it-load-sources $(sort <(compgen -G "./${2}/enabled/*.bash"))
			;;
	esac
fi

unset _bash_it_config_file
unset _bash_it_config_type
popd > /dev/null || exit 1
