cite about-plugin
about-plugin 'Init goenv, if installed. Plays nicely with package managers'

# Use a reasonable default to ensure variable is always present
# NOTE: This (currently) matches goenv's built-in default
# NOTE: We don't export it yet, since we might still bail
GOENV_ROOT="${GOENV_ROOT:-${HOME}/.goenv}"

# Look for goenv command, adding to path if needbe
if ! _command_exists goenv && [ -n "${GOENV_ROOT}" ] && [ -x "${GOENV_ROOT}/bin/goenv" ] ; then
	pathmunge "${GOENV_ROOT}/bin"
fi

# If we found the command, we're good to go
if _command_exists goenv ; then
	# Now its safe to export the value
	export GOENV_ROOT

	# Initialize goenv
	# NOTE: In the off-chance that goenv has already been initialized,
	#       it should be safe to re-initialize
	eval "$(goenv init - bash)"
fi
