cite about-plugin
about-plugin 'load goenv, if you are using it'

# Load after basher
# BASH_IT_LOAD_PRIORITY: 275

# Don't modify the environment if we can't find the tool:
# - Check if in $PATH already
# - Check if installed manually to $GOENV_ROOT
# - Check if installed manually to $HOME
_command_exists goenv ||
  [[ -n "$GOENV_ROOT" && -x "$GOENV_ROOT/bin/goenv" ]] ||
  [[ -x "$HOME/.goenv/bin/goenv" ]] ||
  return 0

# Set GOENV_ROOT, if not already set
export GOENV_ROOT="${GOENV_ROOT:-$HOME/.goenv}"

# Add GOENV_ROOT/bin to PATH, if that's where it's installed
if ! _command_exists goenv && [[ -x "$GOENV_ROOT/bin/goenv" ]] ; then
  pathmunge "$GOENV_ROOT/bin"
fi

# Initialize goenv
eval "$(goenv init - bash)"
