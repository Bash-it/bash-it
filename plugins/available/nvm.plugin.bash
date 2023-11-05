# shellcheck shell=bash
about-plugin 'Node.js version manager, https://github.com/nvm-sh/nvm'

# Load after basher
# BASH_IT_LOAD_PRIORITY: 260

export NVM_DIR="${NVM_DIR:-${HOME?}/.nvm}"

if _bash_it_homebrew_check && [[ -s "${BASH_IT_HOMEBREW_PREFIX?}/nvm.sh" ]]; then
	source "${BASH_IT_HOMEBREW_PREFIX?}/nvm.sh"
else
	[[ -s "${NVM_DIR?}/nvm.sh" ]] && source "${NVM_DIR?}/nvm.sh"
fi
