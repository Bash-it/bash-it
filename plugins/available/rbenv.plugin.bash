# shellcheck shell=bash
about-plugin 'load rbenv, if you are using it'

: "${RBENV_ROOT:=$HOME/.rbenv}"
export RBENV_ROOT
pathmunge "$RBENV_ROOT/bin"

if ! _binary_exists rbenv; then
	_log_warning "Unable to locage 'rbenv'."
	return 1
fi

source < <(rbenv init - bash)
