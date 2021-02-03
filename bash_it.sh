#!/usr/bin/env bash

# Only set $BASH_IT if it's not already set
if [[ -z "$BASH_IT" ]]; then
	# Setting $BASH to maintain backwards compatibility
	export BASH_IT=$BASH
	BASH="$(bash -c 'echo $BASH')"
	export BASH
	BASH_IT_OLD_BASH_SETUP=true
fi

# Load composure first, to support function metadata, then create our custom attributes.
# shellcheck disable=SC1090
source "${BASH_IT}"/vendor/github.com/erichs/composure/composure.sh
cite _about _param _example _group _author _version
cite about-alias about-completion about-plugin

# Next, load our logging library so we can give useful feedback to the user
# shellcheck source=./lib/log.bash
source "${BASH_IT}/lib/log.bash"

BASH_IT_LOG_PREFIX='core: main: '

# Check for old installations
if [[ -n "$BASH_IT_OLD_BASH_SETUP" ]]; then
	_log_warning "BASH_IT variable not initialized, please upgrade your bash-it version and reinstall it!"
fi

# For backwards compatibility, look in old BASH_THEME location
if [[ -z "$BASH_IT_THEME" ]]; then
	_log_warning "BASH_IT_THEME variable not initialized, please upgrade your bash-it version and reinstall it!"
	export BASH_IT_THEME="$BASH_THEME"
	unset BASH_THEME
fi

# Load the base libraries ...
# Note: Ordering is important and intentional

# "utilities" - internal functions meant for use within the bash-it codebase
BASH_IT_LOG_PREFIX='lib: utilities: '
_log_debug 'Loading library file ...'
# shellcheck source=./lib/utilities.bash
source "${BASH_IT}/lib/utilities.bash"

# "helpers" - generic functions meant for generic use by end users,
#             often wrappers of functions found in utilities
BASH_IT_LOG_PREFIX='lib: helpers: '
_log_debug 'Loading library file ...'
# shellcheck source=./lib/helpers.bash
source "${BASH_IT}/lib/helpers.bash"

# "search" - allows end users to search for matching aliases, plugins and completions in bash-it
BASH_IT_LOG_PREFIX='lib: search: '
_log_debug 'Loading library file ...'
# shellcheck source=./lib/search.bash
source "${BASH_IT}/lib/search.bash"

# Load aliases, completion, plugins ...
BASH_IT_LOG_PREFIX='core: main: '

# Load the global "enabled" directory
# "family" param is empty so that files get sources in glob order
# shellcheck source=./scripts/reloader.bash
source "${BASH_IT}/scripts/reloader.bash"

# Load enabled aliases, completion, plugins
for file_type in 'aliases' 'plugins' 'completion'; do
	# shellcheck source=./scripts/reloader.bash
	source "${BASH_IT}/scripts/reloader.bash" 'skip' "$file_type"
done

# Load theme, if a theme was set
if [[ -n "${BASH_IT_THEME}" ]]; then
	_log_debug "Loading \"${BASH_IT_THEME}\" theme..."

	# Load colors and helpers first so they can be used in base theme
	BASH_IT_LOG_PREFIX='themes: colors: '
	_log_debug 'Loading theme file ...'
	# shellcheck source=./themes/colors.theme.bash
	source "${BASH_IT}/themes/colors.theme.bash"

	BASH_IT_LOG_PREFIX='themes: githelpers: '
	_log_debug 'Loading theme file ...'
	# shellcheck source=./themes/githelpers.theme.bash
	source "${BASH_IT}/themes/githelpers.theme.bash"

	BASH_IT_LOG_PREFIX='themes: p4helpers: '
	_log_debug 'Loading theme file ...'
	# shellcheck source=./themes/p4helpers.theme.bash
	source "${BASH_IT}/themes/p4helpers.theme.bash"

	BASH_IT_LOG_PREFIX='themes: command_duration: '
	_log_debug 'Loading theme file ...'
	# shellcheck source=./themes/command_duration.theme.bash
	source "${BASH_IT}/themes/command_duration.theme.bash"

	BASH_IT_LOG_PREFIX='themes: base: '
	_log_debug 'Loading theme file ...'
	# shellcheck source=./themes/base.theme.bash
	source "${BASH_IT}/themes/base.theme.bash"

	BASH_IT_LOG_PREFIX='lib: appearance: '
	_log_debug 'Loading library file ...'
	# appearance (themes) now, after all dependencies
	# shellcheck source=./lib/appearance.bash
	source "${BASH_IT}/lib/appearance.bash"
fi

# Load custom components ...

BASH_IT_LOG_PREFIX='core: main: '
_log_debug 'Loading custom aliases, completion, plugins...'
for file_type in 'aliases' 'completion' 'plugins'; do
	if [[ -e "${BASH_IT}/${file_type}/custom.${file_type}.bash" ]]; then
		BASH_IT_LOG_PREFIX="${file_type}: custom: "
		_log_debug 'Loading component...'
		# shellcheck disable=SC1090
		source "${BASH_IT}/${file_type}/custom.${file_type}.bash"
	fi
done

BASH_IT_LOG_PREFIX="core: main: "
_log_debug "Loading general custom files..."
CUSTOM="${BASH_IT_CUSTOM:=${BASH_IT}/custom}/*.bash ${BASH_IT_CUSTOM:=${BASH_IT}/custom}/**/*.bash"
for _bash_it_config_file in $CUSTOM; do
	if [[ -e "${_bash_it_config_file}" ]]; then
		filename=$(basename "${_bash_it_config_file}")
		filename=${filename%*.bash}
		BASH_IT_LOG_PREFIX="custom: $filename: "
		_log_debug "Loading custom file..."
		# shellcheck disable=SC1090
		source "$_bash_it_config_file"
	fi
done

unset _bash_it_config_file
if [[ $PROMPT ]]; then
	export PS1="\[""$PROMPT""\]"
fi

# Adding Support for other OSes
PREVIEW="less"

if [ -s /usr/bin/gloobus-preview ]; then
	PREVIEW="gloobus-preview"
elif [ -s /Applications/Preview.app ]; then
	# shellcheck disable=SC2034
	PREVIEW="/Applications/Preview.app"
fi

# Load all the Jekyll stuff
if [ -e "$HOME/.jekyllconfig" ]; then
	# shellcheck disable=SC1090
	. "$HOME/.jekyllconfig"
fi

# BASH_IT_RELOAD_LEGACY is set.
if ! command -v reload &> /dev/null && [ -n "$BASH_IT_RELOAD_LEGACY" ]; then
	case $OSTYPE in
		darwin*)
			alias reload='source ~/.bash_profile'
			;;
		*)
			alias reload='source ~/.bashrc'
			;;
	esac
fi

# Now that everything is loaded and configured, load the previewer
BASH_IT_LOG_PREFIX='lib: preview: '
# and the associated preview script
# shellcheck source=./lib/preview.bash
source "${BASH_IT}/lib/preview.bash"

# Disable trap DEBUG on subshells - https://github.com/Bash-it/bash-it/pull/1040
set +T

# Finally, load preexec directly from vendor.
# This has to be last because it wants to have full control over DEBUG trap and PROMPT_COMMAND
BASH_IT_LOG_PREFIX='vendor: bash-preexec: '
# shellcheck source=./vendor/github.com/rcaloras/bash-preexec/bash-preexec.sh
source "${BASH_IT}/vendor/github.com/rcaloras/bash-preexec/bash-preexec.sh"
