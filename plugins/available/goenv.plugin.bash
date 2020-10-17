cite about-plugin
about-plugin 'load goenv, if you are using it'

# Don't modify the environment if we can't find the tool:
# - Check if in $PATH already
# - Check if installed manually to $GOENV_ROOT
# - Check if installed manually to $HOME
_command_exists goenv ||
  [[ -n "$GOENV_ROOT" && -x "$GOENV_ROOT/bin/goenv" ]] ||
  [[ -x "$HOME/.goenv/bin/goenv" ]] ||
  return

# Set GOENV_ROOT, if not already set
export GOENV_ROOT="${GOENV_ROOT:-$HOME/.goenv}"

# Add GOENV_ROOT/bin to PATH, if that's where it's installed
! _command_exists goenv && [[ -x "$GOENV_ROOT/bin/goenv" ]] && pathmunge "$GOENV_ROOT/bin"

# Initialize goenv
eval "$(goenv init - bash)"
