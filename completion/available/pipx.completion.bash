#!/usr/bin/env echo run from bash: .
# shellcheck shell=bash disable=SC2148,SC2096
# pipx completion

if _command_exists register-python-argcomplete && _command_exists pipx; then
	eval "$(register-python-argcomplete pipx)"
fi
