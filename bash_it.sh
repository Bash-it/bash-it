#!/usr/bin/env bash
#
# Initialize Bash It

# Only set $BASH_IT if it's not already set
: "${BASH_IT:=${BASH_SOURCE%/*}}"
: "${BASH_IT_CUSTOM:=${BASH_IT}/custom}"
: "${CUSTOM_THEME_DIR:="${BASH_IT_CUSTOM}/themes"}"
# Store the rcfile for later
: "${BASH_IT_BASHRC:=${BASH_SOURCE[${#BASH_SOURCE[@]} - 1]}}"

# Load composure first, so we support function metadata
# shellcheck source-path=SCRIPTDIR/vendor/github.com/erichs/composure
source "${BASH_IT}/vendor/github.com/erichs/composure/composure.sh"
# support 'plumbing' metadata
cite _about _param _example _group _author _version
cite about-alias about-plugin about-completion

# We need to load logging module early in order to be able to log
# shellcheck source-path=SCRIPTDIR/lib
source "${BASH_IT}/lib/log.bash"

# We can log now; sanity checks
BASH_IT_LOG_PREFIX="core: main: "
if [[ -d "${BASH}" ]]; then
	_log_warning "BASH variable initialized improperly, please upgrade your bash-it version!"
	BASH="$(bash -c 'echo $BASH')"
fi

# libraries, but skip appearance (themes) for now
_log_debug "Loading libraries(except appearance)..."
APPEARANCE_LIB="${BASH_IT}/lib/appearance.bash"
for _bash_it_lib_file in "${BASH_IT}"/lib/*.bash "${BASH_IT}/vendor/init.d"/*.bash; do
	[[ "$_bash_it_lib_file" == "$APPEARANCE_LIB" ]] && continue
	_bash-it-log-prefix-by-path "${_bash_it_lib_file}"
	_log_debug "Loading library file..."
	# shellcheck source-path=SCRIPTDIR/lib;SCRIPTDIR/vendor/init.d disable=SC1090
	source "$_bash_it_lib_file"
done
unset _bash_it_lib_file

BASH_IT_LOG_PREFIX="core: main: "
# Load the global "enabled" directory
# "family" param is empty so that files get sources in glob order
# shellcheck source=./scripts/reloader.bash
source "${BASH_IT}/scripts/reloader.bash"

# Load enabled aliases, completion, plugins
for file_type in "aliases" "plugins" "completion"; do
	# shellcheck source-path=SCRIPTDIR/scripts
	source "${BASH_IT}/scripts/reloader.bash" "skip" "$file_type"
done

# Load theme, if a theme was set
# For backwards compatibility, look in old BASH_THEME location
if [[ -n "${BASH_IT_THEME:="${BASH_THEME:-}"}" ]]; then
	if [[ -n "${BASH_THEME:-}" ]]; then
		_log_warning "BASH_THEME variable is set, please use BASH_IT_THEME instead!"
		unset BASH_THEME
	fi

	_log_debug "Loading \"${BASH_IT_THEME}\" theme..."
	# Load colors and helpers first so they can be used in base theme
	BASH_IT_LOG_PREFIX="themes: colors: "
	# shellcheck source-path=SCRIPTDIR/themes
	source "${BASH_IT}/themes/colors.theme.bash"
	BASH_IT_LOG_PREFIX="themes: githelpers: "
	# shellcheck source-path=SCRIPTDIR/themes
	source "${BASH_IT}/themes/githelpers.theme.bash"
	BASH_IT_LOG_PREFIX="themes: p4helpers: "
	# shellcheck source-path=SCRIPTDIR/themes
	source "${BASH_IT}/themes/p4helpers.theme.bash"
	BASH_IT_LOG_PREFIX="themes: command_duration: "
	# shellcheck source-path=SCRIPTDIR/themes
	source "${BASH_IT}/themes/command_duration.theme.bash"
	BASH_IT_LOG_PREFIX="themes: base: "
	# shellcheck source-path=SCRIPTDIR/themes
	source "${BASH_IT}/themes/base.theme.bash"

	BASH_IT_LOG_PREFIX="lib: appearance: "
	# appearance (themes) now, after all dependencies
	# shellcheck source=./lib/appearance.bash
	source "$APPEARANCE_LIB"
else
	_log_warning "BASH_IT_THEME variable not initialized, please upgrade your bash-it version!"
fi

BASH_IT_LOG_PREFIX="core: main: "
_log_debug "Loading custom aliases, completion, plugins..."
for file_type in "aliases" "completion" "plugins"; do
	_bash_it_custom_file="${BASH_IT}/${file_type}/custom.${file_type}.bash"
	if [[ -e "${_bash_it_custom_file}" ]]; then
		_bash-it-log-prefix-by-path "${_bash_it_custom_file}"
		_log_debug "Loading component..."
		# shellcheck disable=SC1090
		source "${_bash_it_custom_file}"
	fi
done
unset _bash_it_custom_file

# Custom
BASH_IT_LOG_PREFIX="core: main: "
_log_debug "Loading general custom files..."
for _bash_it_custom_file in "$BASH_IT_CUSTOM"/*.bash "$BASH_IT_CUSTOM"/*/*.bash; do
	if [[ -e "${_bash_it_custom_file}" ]]; then
		_bash-it-log-prefix-by-path "${_bash_it_custom_file}"
		_log_debug "Loading custom file..."
		# shellcheck disable=SC1090
		source "$_bash_it_custom_file"
	fi
done
unset _bash_it_custom_file

if [[ -n "${PROMPT:-}" ]]; then
	PS1="\[""$PROMPT""\]"
fi

# Adding Support for other OSes
PREVIEW="less"
if [[ -s /usr/bin/gloobus-preview ]]; then
	PREVIEW="gloobus-preview"
elif [[ -s /Applications/Preview.app ]]; then
	# shellcheck disable=SC2034
	PREVIEW="/Applications/Preview.app"
fi

# Load all the Jekyll stuff

if [[ -e "$HOME/.jekyllconfig" ]]; then
	# shellcheck disable=SC1090
	source "$HOME/.jekyllconfig"
fi

# BASH_IT_RELOAD_LEGACY is set.
# shellcheck disable=SC2139
if ! _command_exists reload && [[ -n "${BASH_IT_RELOAD_LEGACY:-}" ]]; then
	if shopt -q login_shell; then
		alias reload="source '${BASH_IT_BASHRC:-$HOME/.bash_profile}'"
	else
		alias reload="source '${BASH_IT_BASHRC:-$HOME/.bashrc}'"
	fi
fi

# Disable trap DEBUG on subshells - https://github.com/Bash-it/bash-it/pull/1040
set +T
