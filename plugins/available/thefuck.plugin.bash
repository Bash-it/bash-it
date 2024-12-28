# shellcheck shell=bash
about-plugin 'Initialization for fuck'

# https://github.com/nvbn/thefuck

if ! _binary_exists thefuck; then
	_log_warning "Unable to locate 'thefuck'."
	return 1
fi

# shellcheck disable=SC1090
source < <(thefuck --alias)
