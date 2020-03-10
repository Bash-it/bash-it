cite about-plugin
about-plugin 'Init goenv, if installed. Plays nicely with package managers'

# Look for goenv command
if ! _command_exists goenv ; then
	# Add it to the path if we find it, bail otherwise
	if [ -n "${GOENV_ROOT}" ] && [ -x "${GOENV_ROOT}/bin/goenv" ] ; then
		pathmunge "${GOENV_ROOT}/bin"
	elif [ -x "${HOME}/.goenv/bin/goenv" ]; then
		pathmunge "${HOME}/.goenv/bin"
	else
		return
	fi
fi

# Use a reasonable default to ensure variable is always present
# NOTE: This (currently) matches goenv's built-in default
export GOENV_ROOT="${GOENV_ROOT:-${HOME}/.goenv}"

# Initialize goenv
# NOTE: In the off-chance that goenv has already been initialized,
#       it should be safe to re-initialize
eval "$(goenv init - bash)"
