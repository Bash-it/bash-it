# shellcheck shell=bash
about-plugin 'load git-subrepo if you are using it, and initialize completions'

if [[ -s "${GIT_SUBREPO_ROOT:=$HOME/.git-subrepo}/init" ]]; then
	# shellcheck disable=SC1091
	source "$GIT_SUBREPO_ROOT/init"
fi
