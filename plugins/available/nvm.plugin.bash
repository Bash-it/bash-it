# shellcheck shell=bash
about-plugin 'node version manager configuration'

# Bash-it no longer bundles nvm, as this was quickly becoming outdated.
# Please install nvm from https://github.com/creationix/nvm.git if you want to use it.

# BASH_IT_LOAD_PRIORITY: 225

export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

# first check if NVM is managed by brew
NVM_BREW_PREFIX=""
if _bash_it_homebrew_check; then
	NVM_BREW_PREFIX=$(brew --prefix nvm 2> /dev/null)
fi

# This loads nvm
if [[ -n "$NVM_BREW_PREFIX" && -s "${NVM_BREW_PREFIX}/nvm.sh" ]]; then
	# shellcheck disable=SC1091
	source "${NVM_BREW_PREFIX}/nvm.sh"
else
	# shellcheck disable=SC1091
	[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
fi

# shellcheck disable=SC1091 # This loads nvm
if _bash_it_homebrew_check && [[ -s "${BASH_IT_HOMEBREW_PREFIX?}/opt/nvm/nvm.sh" ]]; then
	mkdir -p "${NVM_DIR}"
	source "${BASH_IT_HOMEBREW_PREFIX?}/opt/nvm/nvm.sh"
elif [[ -s "${NVM_DIR}/nvm.sh" ]]; then
	source "${NVM_DIR}/nvm.sh"
fi

if ! _command_exists nvm; then
	_log_warning "Bash-it no longer bundles the nvm script. Please install the latest version from
	https://github.com/creationix/nvm.git or Homebrew"
	_log_warning "if you want to use nvm. You can keep this plugin enabled once you have installed nvm."
	return 1
fi
