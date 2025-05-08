# shellcheck shell=bash
#
# BASH_IT_LOAD_PRIORITY: 225
#
# Bash-it no longer bundles nvm, as this was quickly becoming outdated.
# Please install nvm from https://github.com/creationix/nvm.git if you want to use it.

cite about-plugin
about-plugin 'node version manager configuration'

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

if ! _command_exists nvm; then
	function nvm() {
		echo "Bash-it no longer bundles the nvm script. Please install the latest version from"
		echo ""
		echo "https://github.com/creationix/nvm.git"
		echo ""
		echo "if you want to use nvm. You can keep this plugin enabled once you have installed nvm."
	}

	nvm
fi
