# shellcheck shell=bash
cite about-plugin
about-plugin 'set textmate as a default editor'

if _command_exists mate; then
	EDITOR="$(type -p mate) -w"
	GIT_EDITOR="$EDITOR"
	export EDITOR GIT_EDITOR
fi
