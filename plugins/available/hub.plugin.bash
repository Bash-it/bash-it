# shellcheck shell=bash
cite about-plugin
about-plugin 'load hub, if you are using it'

if _command_exists hub; then
	eval "$(hub alias -s)"
fi
