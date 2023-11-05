# shellcheck shell=bash
about-plugin 'Node.js helper functions'

# Load after *env plugins
# BASH_IT_LOAD_PRIORITY: 270

# Ensure local modules are preferred in PATH
pathmunge './node_modules/.bin' 'after'

# If not using an *env tool, ensure global modules are in PATH
if [[ ! "$(type -p npm)" == *'/shims/npm' ]]; then
	pathmunge "$(npm config get prefix)/bin" 'after'
fi
