# shellcheck shell=bash
about-plugin 'load nodenv, if you are using it'

if [[ -d "${NODENV_ROOT:=$HOME/.nodenv}/bin" ]]; then
	export NODENV_ROOT
	pathmunge "$NODENV_ROOT/bin"
fi

if ! _binary_exists nodenv; then
	_log_warning "Unable to locage 'nodenv'."
	return 1
fi

# shellcheck disable=SC1090
source < <(nodenv init - bash)
