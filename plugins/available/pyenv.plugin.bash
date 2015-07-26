cite about-plugin
about-plugin 'load pyenv, if you are using it'

export PYENV_ROOT="$HOME/.pyenv"
pathmunge "$PYENV_ROOT/bin"

[[ `which pyenv` ]] && eval "$(pyenv init -)"

#Load pyenv virtualenv if the virtualenv plugin is installed.
if pyenv virtualenv-init - &> /dev/null; then
  eval "$(pyenv virtualenv-init -)"
fi

# Load the auto-completion script if pyenv was loaded.
[[ -e $PYENV_ROOT/completions/pyenv.bash ]] && source $PYENV_ROOT/completions/pyenv.bash
