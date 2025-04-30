# shellcheck shell=bash

if _command_exists kind; then
	eval "$(kind completion bash)"
fi
