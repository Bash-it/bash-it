cite about-plugin
about-plugin 'Node.js helper functions'

# Load after nodenv
# BASH_IT_LOAD_PRIORITY: 285

# Check node version to ensure nodenv can find node
{ _command_exists node && node --version &>/dev/null ; } || return 0

# Check npm version to ensure nodenv can find npm
{ _command_exists npm && npm --version &>/dev/null ; } || return 0

# Ensure global modules are in PATH
pathmunge "$(npm config get prefix)/bin"

# Ensure local modules are in PATH
pathmunge './node_modules/.bin'
