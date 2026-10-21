# shellcheck shell=bash
# shellcheck disable=SC2034 # Expected behavior for themes.
# Wrapper to use liquidprompt with _Bash It_, if already installed by the user.
# See themes/liquidprompt/README.md for why this doesn't install it for you.

# Documented clone location first, then PATH (e.g. distribution packages).
_bash_it_liquidprompt_script="${HOME-}/liquidprompt/liquidprompt"
if [[ ! -f "${_bash_it_liquidprompt_script}" ]]; then
	_bash_it_liquidprompt_script="$(type -P liquidprompt)"
fi

if [[ -f "${_bash_it_liquidprompt_script}" ]]; then
	# shellcheck disable=SC1090
	source "${_bash_it_liquidprompt_script}"
else
	_log_warning "The liquidprompt script was not found in ~/liquidprompt or on your PATH. Bash-it does not install or vendor liquidprompt, please see themes/liquidprompt/README.md for more info."
fi
unset -v _bash_it_liquidprompt_script
