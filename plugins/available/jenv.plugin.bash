# shellcheck shell=bash
cite about-plugin
about-plugin 'load jenv, if you are using it'

# Don't modify the environment if we can't find the tool:
# - Check if in $PATH already
# - Check if installed manually to $JENV_ROOT
# - Check if installed manually to $HOME
if ! _binary_exists jenv && 
  ! [[ -n "${JENV_ROOT:-}" && -x "$JENV_ROOT/bin/jenv" ]] &&
  ! [[ -x "$HOME/.jenv/bin/jenv" ]]; then
	_log_warning "Unable to locate 'jenv'."
	return 1
fi

# Set JENV_ROOT, if not already set
: "${JENV_ROOT:=$HOME/.jenv}"
export JENV_ROOT

# Add JENV_ROOT/bin to PATH, if that's where it's installed
if ! _command_exists jenv && [[ -x "$JENV_ROOT/bin/jenv" ]]; then
	pathmunge "$JENV_ROOT/bin"
fi

# shellcheck disable=SC1090 # Initialize jenv
source < <(jenv init - bash)
