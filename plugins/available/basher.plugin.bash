#!/usr/bin/env echo run from bash: .
# shellcheck shell=bash disable=SC2148,SC2096
cite about-plugin
about-plugin 'initializes basher, the shell package manager'

# https://github.com/basherpm/basher

if ! _command_exists basher; then
	if [[ -x "$HOME/.basher/bin/basher" ]]; then
		pathmunge "$HOME/.basher/bin"
	else
		_log_warning 'basher not found'
		return 0
	fi
fi

eval "$(basher init - bash)"
