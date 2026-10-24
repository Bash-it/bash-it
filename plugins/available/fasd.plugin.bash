# shellcheck shell=bash
cite about-plugin
about-plugin 'load fasd, if you are using it'
url "https://github.com/clvv/fasd"

if ! _command_exists fasd; then
	_log_warning "Unable to locage 'fasd'."
	return 1
fi

eval "$(fasd --init auto)"
