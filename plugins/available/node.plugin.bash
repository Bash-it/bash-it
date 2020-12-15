cite about-plugin
about-plugin 'Node.js helper functions'

# Ensure local modules are preferred in PATH
pathmunge "./node_modules/.bin" "after"

# Check that we have npm
out=$(command -v npm 2>&1) || return

# If not using nodenv, ensure global modules are in PATH
if [[ ! $out == *"nodenv/shims"* ]] ; then
  pathmunge "$(npm config get prefix)/bin" "after"
fi
