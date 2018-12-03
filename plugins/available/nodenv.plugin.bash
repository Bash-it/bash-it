cite about-plugin
about-plugin 'load nodenv, if you are using it'

export NODENV_ROOT="$HOME/.nodenv"
pathmunge "$NODENV_ROOT/bin"

[[ `which nodenv` ]] && eval "$(nodenv init - bash)"
