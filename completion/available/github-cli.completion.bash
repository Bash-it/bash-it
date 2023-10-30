# shellcheck shell=bash
cite "about-completion"
about-completion "GitHub CLI completion"

if _binary_exists gh; then
	# If gh already completed, stop
	_completion_exists gh && return
	eval "$(gh completion --shell=bash)"
fi
