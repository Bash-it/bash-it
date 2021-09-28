# shellcheck shell=bash
cite about-plugin
about-plugin 'load pyenv, if you are using it'

# https://github.com/pyenv/pyenv

# Load after basher
# BASH_IT_LOAD_PRIORITY: 260

# Don't modify the environment if we can't find the tool:
# - Check if in $PATH already
# - Check if installed manually to $PYENV_ROOT
# - Check if installed manually to $HOME
_command_exists pyenv \
	|| [[ -n "$PYENV_ROOT" && -x "$PYENV_ROOT/bin/pyenv" ]] \
	|| [[ -x "$HOME/.pyenv/bin/pyenv" ]] \
	|| return 0

# Set PYENV_ROOT, if not already set
export PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"

# Add PYENV_ROOT/bin to PATH, if that's where it's installed
if ! _command_exists pyenv && [[ -x "$PYENV_ROOT/bin/pyenv" ]]; then
	pathmunge "$PYENV_ROOT/bin"
fi

# Initialize pyenv
pathmunge "$PYENV_ROOT/shims"
eval "$(pyenv init - bash)"

# Load pyenv virtualenv if the virtualenv plugin is installed.
if pyenv virtualenv-init - &> /dev/null; then
	eval "$(pyenv virtualenv-init - bash)"
fi
