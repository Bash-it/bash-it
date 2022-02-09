# shellcheck shell=bash
about-plugin 'zoxide is a smarter cd command for your shell.'

if ! _binary_exists zoxide; then
	_log_error 'zoxide not found, please install it from https://github.com/ajeetdsouza/zoxide'
	return 1
fi

source < <(zoxide init bash)
