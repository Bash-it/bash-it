# shellcheck shell=bash
# shellcheck disable=SC2034 # Expected behavior for themes.
# Wrapper to use liquidprompt with _Bash It_, if already installed by the user.
# See themes/liquidprompt/README.md for why this doesn't install it for you.

if _command_exists liquidprompt; then
	# shellcheck disable=SC1090
	source "$(command -v liquidprompt)"
else
	_log_warning "The liquidprompt script was not found on your PATH. Bash-it does not install or vendor liquidprompt, please see themes/liquidprompt/README.md for more info."
fi
