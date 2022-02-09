# shellcheck shell=bash
about-plugin 'node version manager configuration'

# Bash-it no longer bundles nvm, as this was quickly becoming outdated.
# Please install nvm from https://github.com/creationix/nvm.git if you want to use it.

# BASH_IT_LOAD_PRIORITY: 225

: "${NVM_DIR:=$HOME/.nvm}"
export NVM_DIR

# shellcheck disable=SC1091 # This loads nvm
if _bash_it_homebrew_check && [[ -s "${BASH_IT_HOMEBREW_PREFIX?}/nvm.sh" ]]; then
	source "${BASH_IT_HOMEBREW_PREFIX?}/nvm.sh"
elif [[ -s "${NVM_DIR}/nvm.sh" ]]; then
	source "${NVM_DIR}/nvm.sh"
fi

if ! _command_exists nvm; then
	_log_warning "Bash-it no longer bundles the nvm script. Please install the latest version from
	https://github.com/creationix/nvm.git"
	_log_warning "if you want to use nvm. You can keep this plugin enabled once you have installed nvm."
	return 1
fi
