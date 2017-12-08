cite about-plugin
about-plugin 'load direnv, if you are using it'

[ -x "$(which direnv)" ] && eval "$(direnv hook bash)"
