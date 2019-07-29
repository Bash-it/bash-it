cite about-plugin
about-plugin 'load pyenv, if you are using it'

export PYENV_ROOT="$HOME/.pyenv"
pathmunge "$PYENV_ROOT/bin"

[[ `which pyenv 2>/dev/null` ]] && eval "$(pyenv init - bash)"

#Load pyenv virtualenv if the virtualenv plugin is installed.
if pyenv virtualenv-init - &> /dev/null; then
  eval "$(pyenv virtualenv-init - bash)"
fi
