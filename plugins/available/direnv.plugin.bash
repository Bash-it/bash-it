# shellcheck shell=bash
about-plugin 'load direnv, if you are using it: https://direnv.net/'

if ! _binary_exists direnv; then
	_log_warning "Could not find 'direnv'."
	return 1
fi

# shellcheck disable=SC1090
source < <(direnv hook bash)
