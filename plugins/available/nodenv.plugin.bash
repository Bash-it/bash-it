# shellcheck shell=bash
about-plugin 'Node.js environment management using https://github.com/nodenv/nodenv'

# Load after basher
# BASH_IT_LOAD_PRIORITY: 260

export NODENV_ROOT="${NODENV_ROOT:-${HOME?}/.nodenv}"

if [[ -d "${NODENV_ROOT?}/bin" ]]; then
	pathmunge "${NODENV_ROOT?}/bin"
fi

if _command_exists nodenv; then
	eval "$(nodenv init - bash)"
fi
