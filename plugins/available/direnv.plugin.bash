# shellcheck shell=bash
cite about-plugin
about-plugin 'load direnv, if you are using it: https://direnv.net/'

if _command_exists direnv; then
	eval "$(direnv hook bash)"
fi
