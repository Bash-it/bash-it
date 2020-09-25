cite about-plugin
about-plugin 'load rbenv, if you are using it'

# Load after basher
# BASH_IT_LOAD_PRIORITY: 275

# Don't modify the environment if we can't find the tool:
# - Check if in $PATH already
# - Check if installed manually to $RBENV_ROOT
# - Check if installed manually to $HOME
_command_exists rbenv ||
  [[ -n "$RBENV_ROOT" && -x "$RBENV_ROOT/bin/rbenv" ]] ||
  [[ -x "$HOME/.rbenv/bin/rbenv" ]] ||
  return 0

# Set RBENV_ROOT, if not already set
export RBENV_ROOT="${RBENV_ROOT:-$HOME/.rbenv}"

# Add RBENV_ROOT/bin to PATH, if that's where it's installed
if ! _command_exists rbenv && [[ -x "$RBENV_ROOT/bin/rbenv" ]] ; then
  pathmunge "$RBENV_ROOT/bin"
fi

# Initialize rbenv
eval "$(rbenv init - bash)"
