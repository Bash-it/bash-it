# shellcheck shell=bash
#
# plugin for plenv

cite about-plugin
about-plugin 'plenv plugin for Perl'

if [[ -d "${HOME}/.plenv/bin" ]]; then
	# load plenv bin dir into path if it exists
	pathmunge "${HOME}/.plenv/bin"
fi

if _command_exists plenv; then
	# init plenv
	eval "$(plenv init - bash)"
fi
