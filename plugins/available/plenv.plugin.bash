# shellcheck shell=bash
about-plugin 'plenv plugin for Perl'
url "https://github.com/tokuhirom/plenv"

if [[ -d "${HOME}/.plenv/bin" ]]; then
	# load plenv bin dir into path if it exists
	pathmunge "${HOME}/.plenv/bin"
fi

if ! _binary_exists plenv; then
	_log_warning "Unable to locage 'plenv'."
	return 1
fi

# shellcheck disable=SC1090 # init plenv
source < <(plenv init - bash)
