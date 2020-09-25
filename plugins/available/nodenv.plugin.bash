cite about-plugin
about-plugin 'load nodenv, if you are using it'

# Load after basher
# BASH_IT_LOAD_PRIORITY: 275

# Don't modify the environment if we can't find the tool:
# - Check if in $PATH already
# - Check if installed manually to $NODENV_ROOT
# - Check if installed manually to $HOME
_command_exists nodenv ||
  [[ -n "$NODENV_ROOT" && -x "$RBENV_ROOT/bin/nodenv" ]] ||
  [[ -x "$HOME/.nodenv/bin/nodenv" ]] ||
  return 0

# Set NODENV_ROOT, if not already set
export NODENV_ROOT="${NODENV_ROOT:-$(nodenv root)}"

# Add NODENV_ROOT/bin to PATH, if that's where it's installed
if ! _command_exists nodenv && [[ -x "$NODENV_ROOT/bin/nodenv" ]] ; then
  pathmunge "$NODENV_ROOT/bin"
fi

eval "$(nodenv init - bash)"
