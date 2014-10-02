cite about-plugin
about-plugin 'load pyenv, if you are using it'

export PYENV_PATH=`which pyenv`
export PATH="$PYENV_PATH:$PATH"

[[ `which pyenv` ]] && eval "$(pyenv init -)"

# Load the auto-completion script if pyenv was loaded.
[[ -e $PYENV_ROOT/completions/pyenv.bash ]] && source $PYENV_ROOT/completions/pyenv.bash
