cite about-plugin
about-plugin 'load nodenv, if you are using it'

export NODENV_ROOT="$HOME/.nodenv"
pathmunge "$NODENV_ROOT/bin"

[[ `which nodenv` ]] && eval "$(nodenv init -)"

# Load the auto-completion script if nodenv was loaded.
[[ -e $NODENV_ROOT/completions/nodenv.bash ]] && source $NODENV_ROOT/completions/nodenv.bash
