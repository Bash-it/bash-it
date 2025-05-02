# shellcheck shell=bash
about-completion "nvm (Node Version Manager) completion"

if [[ -n "${NVM_DIR:-}" && -s "${NVM_DIR}/bash_completion" ]]; then
	# shellcheck disable=SC1091
	source "${NVM_DIR}/bash_completion"
fi
