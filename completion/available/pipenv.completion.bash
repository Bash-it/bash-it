# shellcheck shell=bash
if _command_exists pipenv; then
	eval "$(_PIPENV_COMPLETE=bash_source pipenv)"
fi
