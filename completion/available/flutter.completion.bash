# shellcheck shell=bash

if _command_exists flutter; then
	eval "$(flutter bash-completion)"
fi
