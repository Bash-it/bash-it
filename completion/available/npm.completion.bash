# shellcheck shell=bash
about-completion "npm (Node Package Manager) completion"

# Test `npm version` because *env tools create shim scripts that will be found in PATH
# but do not always resolve to a working install.
if _command_exists npm && npm --version &> /dev/null; then
	eval "$(npm completion)"
fi
