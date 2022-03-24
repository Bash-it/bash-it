# shellcheck shell=bash
cite about-plugin
about-plugin 'Node.js helper functions'

# Check that we have npm
_command_exists npm || return

# Ensure local modules are preferred in PATH
pathmunge "./node_modules/.bin" "after"

# If not using nodenv, ensure global modules are in PATH
if [[ ! "$(type -p npm)" == *"nodenv/shims"* ]]; then
	pathmunge "$(npm config get prefix)/bin" "after"
fi
