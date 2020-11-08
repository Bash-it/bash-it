# Bash-it no longer bundles nvm, as this was quickly becoming outdated.
#
# BASH_IT_LOAD_PRIORITY: 225
#
# Please install nvm from https://github.com/creationix/nvm.git if you want to use it.

cite about-plugin
about-plugin 'node version manager configuration'

export NVM_DIR=${NVM_DIR:-$HOME/.nvm}
# This loads nvm
if [ -s "$NVM_DIR/nvm.sh" ]
then
  source "$NVM_DIR/nvm.sh"
else
  if command -v brew &>/dev/null && [ -s $(brew --prefix nvm)/nvm.sh ]
  then
    source $(brew --prefix nvm)/nvm.sh
  fi
fi


if ! command -v nvm &>/dev/null
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
