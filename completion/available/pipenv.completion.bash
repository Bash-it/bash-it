# shellcheck shell=bash
if _command_exists pipenv; then
	eval "$(pipenv --completion)"
fi
