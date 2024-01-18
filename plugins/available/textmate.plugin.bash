# shellcheck shell=bash
about-plugin 'set textmate as a default editor'

if ! _binary_exists mate; then
	_log_warning "Unable to locage 'mate'."
	return 1
fi

EDITOR="$(type -p mate) -w"
export EDITOR
