cite about-plugin
about-plugin 'Init goenv, if installed. Plays nicely with package managers'

# GOENV_ROOT does not need to be configured.
# If it is configured, it should not be overridden.
# However, let's try to handle the case where:
# - goenv is not already on the path
# - GOENV_ROOT is not configured
# - User has installed goenv in ~/.goenv
# In this case, we'll do the user a solid and configure
# the goenv they've taken the time to install.
if ! _command_exists goenv && [ -z "${GOENV_ROOT}" ] && [ -x "${HOME}/.goenv/bin/goenv" ]; then
	export GOENV_ROOT="${HOME}/.goenv"
fi

# Add GOENV_ROOT/bin to path if:
# - goenv not already on path
# - GOENV_ROOT is configured
# - User has installed goenv in GOENV_ROOT
if ! _command_exists goenv && [ -n "${GOENV_ROOT}" ] && [ -x "${GOENV_ROOT}/bin/goenv" ]; then
	pathmunge "${GOENV_ROOT}/bin"
fi

# Initialize goenv - Play nicely if goenv never made it to the path
# NOTE: In the off-chance that goenv has already been initialized,
#       it should be safe to re-initialize
if _command_exists goenv ; then
	eval "$(goenv init - bash)"
fi
