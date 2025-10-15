# shellcheck shell=bash
cite about-plugin
about-plugin 'load rbenv, if you are using it'
url "https://github.com/rbenv/rbenv"

export RBENV_ROOT="$HOME/.rbenv"
pathmunge "$RBENV_ROOT/bin"

if _command_exists rbenv; then
	eval "$(rbenv init - bash)"
fi
