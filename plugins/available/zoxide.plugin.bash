# shellcheck shell=bash
cite about-plugin
about-plugin 'zoxide is a smarter cd command for your shell.'

if _command_exists zoxide; then
	eval "$(zoxide init bash)"
else
	_log_error 'zoxide not found, please install it from https://github.com/ajeetdsouza/zoxide'
fi
