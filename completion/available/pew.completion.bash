# shellcheck shell=bash

if _command_exists pew; then
	# shellcheck disable=SC1090
	source "$(pew shell_config)"
fi
