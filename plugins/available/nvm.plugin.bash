# Bash-it no longer bundles nvm, as this was quickly becoming outdated.
#
# Please install nvm from https://github.com/creationix/nvm.git if you want to use it.

cite about-plugin
about-plugin 'node version manager configuration'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

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
