# shellcheck shell=bash

if _command_exists oh-my-posh; then
	export POSH_THEME=${POSH_THEME:-https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/v$(oh-my-posh --version)/themes/jandedobbeleer.omp.json}
	eval "$(oh-my-posh init bash --config "${POSH_THEME}")"
else
	_log_warning "The oh-my-posh binary was not found on your PATH. Falling back to your existing PS1, please see the docs for more info."
fi
