# shellcheck shell=bash
about-plugin 'Node.js environment management using https://github.com/ryuone/nenv'

# Load after basher
# BASH_IT_LOAD_PRIORITY: 260

export NENV_ROOT="${NENV_ROOT:-${HOME?}/.nenv}"

if [[ -d "${NENV_ROOT?}/bin" ]]; then
	pathmunge "${NENV_ROOT?}/bin"
fi

if _command_exists nenv; then
	eval "$(nenv init - bash)"
fi
