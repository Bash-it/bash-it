# shellcheck shell=bash
about-alias 'Curl aliases for convenience.'

# set apt aliases
function _set_pkg_aliases() {
	if _command_exists curl; then
		# follow redirects
		alias cl='curl -L'
		# follow redirects, download as original name
		alias clo='curl -L -O'
		# follow redirects, download as original name, continue
		alias cloc='curl -L -C - -O'
		# follow redirects, download as original name, continue, retry 5 times
		alias clocr='curl -L -C - -O --retry 5'
		# follow redirects, fetch banner
		alias clb='curl -L -I'
		# see only response headers from a get request
		alias clhead='curl -D - -so /dev/null'
	fi
}

_set_pkg_aliases
