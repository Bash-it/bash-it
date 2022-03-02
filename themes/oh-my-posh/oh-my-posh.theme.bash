# shellcheck shell=bash

if _command_exists oh-my-posh; then
	export POSH_THEME=${POSH_THEME:-https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/v$(oh-my-posh --version)/themes/jandedobbeleer.omp.json}
	eval "$(oh-my-posh --init --shell bash --config "${POSH_THEME}")"
else
	_log_warning "The oh-my-posh binary was not found on your \$PATH."
	_log_warning "Falling back to your existing \$PS1."
	_log_warning
	_log_warning "*** Note:"
	_log_warning "The oh-my-posh ״theme״ is really a plug to a whole other system"
	_log_warning "of managing your prompt. To use it please start here:"
	_log_warning "https://ohmyposh.dev/"
	_log_warning
	_log_warning "It is beyond the scope of bash-it to install and manage oh-my-posh,"
	_log_warning "this theme is here just to make sure your OMP setup doesn't clash"
	_log_warning "with other bash-it themes. Once installed, OMP will load a default"
	_log_warning "OMP theme (jandedobbeleer), which you can then"
	_log_warning "customize or override."
fi
