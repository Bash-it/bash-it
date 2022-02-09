# shellcheck shell=bash
about-plugin 'load fasd, if you are using it'

if ! _binary_exists fasd; then
	_log_warning "Unable to locage 'fasd'."
	return 1
fi

# shellcheck disable=SC1090
source < <(fasd --init auto)
