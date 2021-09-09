# shellcheck shell=bash
#
# BASH_IT_LOAD_PRIORITY: 225
#
# Bash-it no longer bundles nvm, as this was quickly becoming outdated.
# Please install nvm from https://github.com/creationix/nvm.git if you want to use it.

cite about-plugin
about-plugin 'node version manager configuration'

export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
# This loads nvm
if _bash_it_homebrew_check && [[ -s "${BASH_IT_HOMEBREW_PREFIX}/nvm.sh" ]]
then
  source "${BASH_IT_HOMEBREW_PREFIX}/nvm.sh"
else
  [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
fi

if ! _command_exists nvm
then
  function nvm() {
    echo "Bash-it no longer bundles the nvm script. Please install the latest version from"
    echo ""
    echo "https://github.com/creationix/nvm.git"
    echo ""
    echo "if you want to use nvm. You can keep this plugin enabled once you have installed nvm."
  }

  nvm
fi
