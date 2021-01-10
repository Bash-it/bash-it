# shellcheck shell=bash
cite "about-completion"
about-completion "npm (Node Package Manager) completion"

if _command_exists npm; then
	eval "$(npm completion)"
fi
