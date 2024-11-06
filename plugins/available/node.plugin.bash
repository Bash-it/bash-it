# shellcheck shell=bash
about-plugin 'Node.js helper functions'

# Check that we have npm
if ! _binary_exists npm; then
	_log_warning "Unable to locage 'npm'."
	return 1
fi

# Ensure local modules are preferred in PATH
pathmunge "./node_modules/.bin" "after"

# If not using nodenv, ensure global modules are in PATH
if [[ "$(type -p npm)" != *"nodenv/shims"* ]]; then
	pathmunge "$(npm config get prefix)/bin" "after"
fi
