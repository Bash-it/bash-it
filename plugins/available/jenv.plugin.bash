# shellcheck shell=bash
cite about-plugin
about-plugin 'load jenv, if you are using it'

# Don't modify the environment if we can't find the tool:
# - Check if in $PATH already
# - Check if installed manually to $JENV_ROOT
# - Check if installed manually to $HOME
_command_exists jenv \
	|| [[ -n "$JENV_ROOT" && -x "$JENV_ROOT/bin/jenv" ]] \
	|| [[ -x "$HOME/.jenv/bin/jenv" ]] \
	|| return

# Set JENV_ROOT, if not already set
export JENV_ROOT="${JENV_ROOT:-$HOME/.jenv}"

# Add JENV_ROOT/bin to PATH, if that's where it's installed
! _command_exists jenv \
	&& [[ -x "$JENV_ROOT/bin/jenv" ]] \
	&& pathmunge "$JENV_ROOT/bin"

# Initialize jenv
eval "$(jenv init - bash)"
