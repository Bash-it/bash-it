# shellcheck shell=bash
cite "about-completion"
about-completion "conda completion"

if _command_exists conda; then
	if _command_exists register-python-argcomplete; then
		eval "$(register-python-argcomplete conda)"
	else
		_log_warning "Argcomplete not found. Please run 'conda install argcomplete'"
	fi
fi
