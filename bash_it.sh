#!/usr/bin/env bash
# shellcheck source-path=SCRIPTDIR/lib source-path=SCRIPTDIR/scripts
# shellcheck disable=SC2034
#
# Initialize Bash It
BASH_IT_LOG_PREFIX="core: main: "
: "${BASH_IT:=${BASH_SOURCE%/*}}"
: "${BASH_IT_CUSTOM:=${BASH_IT}/custom}"
: "${CUSTOM_THEME_DIR:="${BASH_IT_CUSTOM}/themes"}"
: "${BASH_IT_BASHRC:=${BASH_SOURCE[${#BASH_SOURCE[@]} - 1]}}"

# Load composure first, so we support function metadata
# shellcheck source-path=SCRIPTDIR/vendor/github.com/erichs/composure
source "${BASH_IT}/vendor/github.com/erichs/composure/composure.sh"
# support 'plumbing' metadata
cite _about _param _example _group _author _version
cite about-alias about-plugin about-completion

# Declare our end-of-main finishing hook, but don't use `declare`/`typeset`
_bash_it_library_finalize_hook=()

# We need to load logging module early in order to be able to log
source "${BASH_IT}/lib/log.bash"

# libraries, but skip appearance (themes) for now
_log_debug "Loading libraries(except appearance)..."
APPEARANCE_LIB="${BASH_IT}/lib/appearance.bash"
for _bash_it_main_file_lib in "${BASH_IT}/lib"/*.bash; do
	[[ "$_bash_it_main_file_lib" == "$APPEARANCE_LIB" ]] && continue
	_bash-it-log-prefix-by-path "${_bash_it_main_file_lib}"
	_log_debug "Loading library file..."
	# shellcheck disable=SC1090
	source "$_bash_it_main_file_lib"
	BASH_IT_LOG_PREFIX="core: main: "
done

# Load the global "enabled" directory, then enabled aliases, completion, plugins
# "_bash_it_main_file_type" param is empty so that files get sourced in glob order
for _bash_it_main_file_type in "" "aliases" "plugins" "completion"; do
	BASH_IT_LOG_PREFIX="core: reloader: "
	# shellcheck disable=SC2140
	source "${BASH_IT}/scripts/reloader.bash" ${_bash_it_main_file_type:+"skip" "$_bash_it_main_file_type"}
	BASH_IT_LOG_PREFIX="core: main: "
done

# Load theme, if a theme was set
# shellcheck source-path=SCRIPTDIR/themes
if [[ -n "${BASH_IT_THEME:-}" ]]; then
	_log_debug "Loading theme '${BASH_IT_THEME}'."
	BASH_IT_LOG_PREFIX="themes: githelpers: "
	source "${BASH_IT}/themes/githelpers.theme.bash"
	BASH_IT_LOG_PREFIX="themes: p4helpers: "
	source "${BASH_IT}/themes/p4helpers.theme.bash"
	BASH_IT_LOG_PREFIX="themes: base: "
	source "${BASH_IT}/themes/base.theme.bash"

	BASH_IT_LOG_PREFIX="lib: appearance: "
	# appearance (themes) now, after all dependencies
	# shellcheck source=SCRIPTDIR/lib/appearance.bash
	source "$APPEARANCE_LIB"
	BASH_IT_LOG_PREFIX="core: main: "
fi

_log_debug "Loading custom aliases, completion, plugins..."
for _bash_it_main_file_type in "aliases" "completion" "plugins"; do
	_bash_it_main_file_custom="${BASH_IT}/${_bash_it_main_file_type}/custom.${_bash_it_main_file_type}.bash"
	if [[ -s "${_bash_it_main_file_custom}" ]]; then
		_bash-it-log-prefix-by-path "${_bash_it_main_file_custom}"
		_log_debug "Loading component..."
		# shellcheck disable=SC1090
		source "${_bash_it_main_file_custom}"
	fi
	BASH_IT_LOG_PREFIX="core: main: "
done

# Custom
_log_debug "Loading general custom files..."
for _bash_it_main_file_custom in "${BASH_IT_CUSTOM}"/*.bash "${BASH_IT_CUSTOM}"/*/*.bash; do
	if [[ -s "${_bash_it_main_file_custom}" ]]; then
		_bash-it-log-prefix-by-path "${_bash_it_main_file_custom}"
		_log_debug "Loading custom file..."
		# shellcheck disable=SC1090
		source "$_bash_it_main_file_custom"
	fi
	BASH_IT_LOG_PREFIX="core: main: "
done

if [[ -n "${PROMPT:-}" ]]; then
	PS1="${PROMPT}"
fi

# Adding Support for other OSes
if _command_exists gloobus-preview; then
	PREVIEW="gloobus-preview"
elif [[ -d /Applications/Preview.app ]]; then
	PREVIEW="/Applications/Preview.app"
else
	PREVIEW="less"
fi

# BASH_IT_RELOAD_LEGACY is set.
if [[ -n "${BASH_IT_RELOAD_LEGACY:-}" ]] && ! _command_exists reload; then
	# shellcheck disable=SC2139
	alias reload="builtin source '${BASH_IT_BASHRC?}'"
fi

for _bash_it_library_finalize_f in "${_bash_it_library_finalize_hook[@]:-}"; do
	eval "${_bash_it_library_finalize_f?}" # Use `eval` to achieve the same behavior as `$PROMPT_COMMAND`.
done
unset "${!_bash_it_library_finalize_@}" "${!_bash_it_main_file_@}"
