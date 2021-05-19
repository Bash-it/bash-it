# shellcheck shell=bash
cite about-plugin
about-plugin 'Initialization for fuck'

# https://github.com/nvbn/thefuck

if _command_exists thefuck; then
	eval "$(thefuck --alias)"
fi
