# shellcheck shell=bash
if _command_exists kontena; then
	# shellcheck disable=SC1090
	source "$(kontena whoami --bash-completion-path)"
fi
