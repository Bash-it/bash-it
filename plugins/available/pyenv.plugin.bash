# shellcheck shell=bash
cite about-plugin
about-plugin 'load pyenv, if you are using it'

export PYENV_ROOT="$HOME/.pyenv"
pathmunge "$PYENV_ROOT/bin"

if _command_exists pyenv; then
	eval "$(pyenv init - bash)"
fi

#Load pyenv virtualenv if the virtualenv plugin is installed.
if pyenv virtualenv-init - &> /dev/null; then
	eval "$(pyenv virtualenv-init - bash)"
fi
