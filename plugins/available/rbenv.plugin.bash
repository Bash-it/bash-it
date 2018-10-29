cite about-plugin
about-plugin 'load rbenv, if you are using it'

export RBENV_ROOT="$HOME/.rbenv"
pathmunge "$RBENV_ROOT/bin"

[[ `which rbenv` ]] && eval "$(rbenv init -)"

# Load the auto-completion script if rbenv was loaded.
[[ -e $RBENV_ROOT/completions/rbenv.bash ]] && source $RBENV_ROOT/completions/rbenv.bash
