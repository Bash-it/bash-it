cite about-plugin
about-plugin 'Init goenv, if installed. Plays nicely with package managers'

# Try to set GOENV_ROOT if not already set
if [ -z "${GOENV_ROOT}" ]; then
	# Bail if cannot be set
	if [ ! -d "$HOME/.goenv" ]; then
		return
	fi
	export GOENV_ROOT="$HOME/.goenv"
fi

# Add GOENV_ROOT/bin to path if goenv not already on path
if ! _command_exists goenv && [ -x "${GOENV_ROOT}/bin/goenv" ]; then
	pathmunge "$GOENV_ROOT/bin"
fi

# Initialize goenv - Play nicely if goenv not on path
if _command_exists goenv ; then
	eval "$(goenv init - bash)"
fi
