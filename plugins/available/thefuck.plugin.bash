# shellcheck shell=bash
cite about-plugin
about-plugin 'Initialization for fuck'

# https://github.com/nvbn/thefuck

if ! _binary_exists thefuck; then
	_log_warning "Unable to locate 'thefuck'."
	return 1
fi

if _command_exists thefuck; then
	# shellcheck disable=SC2046
	eval $(thefuck --alias)
fi

# shellcheck disable=SC1090
source < <(thefuck --alias)
