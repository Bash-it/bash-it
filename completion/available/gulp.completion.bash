# shellcheck shell=bash

if _command_exists gulp; then
	eval "$(gulp --completion=bash)"
fi
