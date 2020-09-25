cite about-plugin
about-plugin 'load pyenv, if you are using it'

# Load after basher
# BASH_IT_LOAD_PRIORITY: 275

# Don't modify the environment if we can't find the tool:
# - Check if in $PATH already
# - Check if installed manually to $PYENV_ROOT
# - Check if installed manually to $HOME
_command_exists pyenv ||
  [[ -n "$PYENV_ROOT" && -x "$PYENV_ROOT/bin/pyenv" ]] ||
  [[ -x "$HOME/.pyenv/bin/pyenv" ]] ||
  return 0

# Set PYENV_ROOT, if not already set
export PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"

# Add PYENV_ROOT/bin to PATH, if that's where it's installed
if ! _command_exists pyenv && [[ -x "$PYENV_ROOT/bin/pyenv" ]] ; then
  pathmunge "$PYENV_ROOT/bin"
fi

# Initialize pyenv
eval "$(pyenv init - bash)"

# Load pyenv virtualenv if the plugin is installed
! _command_exists 'pyenv virtualenv --help' \
  "pyenv plugin 'virtualenv' is not installed - skipping" ||
    eval "$(pyenv virtualenv-init - bash)"
