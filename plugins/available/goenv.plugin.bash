cite about-plugin
about-plugin 'Init goenv, if installed. Plays nicely with package managers'

# Use a reasonable default to ensure variable is always present
# NOTE: This (currently) matches goenv's built-in default
# NOTE: We don't export it yet, since we might still bail
GOENV_ROOT="${GOENV_ROOT:-${HOME}/.goenv}"

# Look for goenv command
if ! _command_exists goenv ; then
	# Add it to the path if we find it, bail otherwise
	if [ -n "${GOENV_ROOT}" ] && [ -x "${GOENV_ROOT}/bin/goenv" ] ; then
		pathmunge "${GOENV_ROOT}/bin"
	else
		return
	fi
fi

# Since we didn't bail, export the value
export GOENV_ROOT

# Initialize goenv
# NOTE: In the off-chance that goenv has already been initialized,
#       it should be safe to re-initialize
eval "$(goenv init - bash)"
