# shellcheck shell=bash
about-plugin 'load hub, if you are using it'

if ! _binary_exists hub; then
	_log_warning "Unable to locate 'hub'."
	return 1
fi

source < <(hub alias -s)
