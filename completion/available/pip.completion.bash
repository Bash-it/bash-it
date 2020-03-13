# https://pip.pypa.io/en/stable/user_guide/#command-completion
# Of course, you should first install the pip, say on Debian:
# sudo apt-get install python-pip
# sudo apt-get install python3-pip

# If the pip package is installed within virtual environments,
# you should first install pip for the corresponding environment.

# Fix pip completion for running it within/outside of pyenv/virtualenv/venv/conda environment.

_pip_completion_hook() {
  local _pip
  # For pip resides within the pyenv/virtualenv/venv/conda environments:
  if [ -n "$VIRTUAL_ENV" ] && [ -x "$VIRTUAL_ENV/bin/pip" ]; then
    _pip="$VIRTUAL_ENV/bin/pip"
  elif [ -n "$CONDA_PREFIX" ] && [ -x "$CONDA_PREFIX/bin/pip" ]; then
    _pip="$CONDA_PREFIX/bin/pip"
  # For pip resides outside of a virtual environment:
  elif [ -x /usr/bin/pip ]; then
    _pip=/usr/bin/pip
  fi
  if [ -n "$_pip" ]; then
    eval "$($_pip completion --bash)"
  fi  
}

if ! [[ "$PROMPT_COMMAND" =~ _pip_completion_hook ]]; then
  PROMPT_COMMAND="_pip_completion_hook;$PROMPT_COMMAND";
fi




