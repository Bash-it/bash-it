cite about-plugin
about-plugin 'load rbenv, if you are using it'

export RBENV_ROOT="$HOME/.rbenv"
pathmunge "$RBENV_ROOT/bin"

[[ `which rbenv 2>/dev/null` ]] && eval "$(rbenv init - bash)"
