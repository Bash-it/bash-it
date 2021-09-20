# shellcheck shell=bash
cite about-plugin
about-plugin 'load nodenv, if you are using it'

export NODENV_ROOT="$HOME/.nodenv"
pathmunge "$NODENV_ROOT/bin"

if _command_exists nodenv; then
	eval "$(nodenv init - bash)"
fi
