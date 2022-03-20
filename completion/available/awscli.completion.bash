# shellcheck shell=bash

if _command_exists aws_completer; then
	complete -C "$(command -v aws_completer)" aws
fi
