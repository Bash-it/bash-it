# shellcheck shell=bash
about-completion "Herdr Terminal Multiplexer tab completion"

if ! _binary_exists herdr; then
	_log_error "herdr not found in PATH — completion not loaded. (${BASH_SOURCE[0]})"
	return 1
else
	if ! _bash-it-completion-helper-sufficient herdr; then
		_log_warning "The completion is set for 'herdr' externally. Activation will be skipped. (${BASH_SOURCE[0]})"
	else
		eval "$(herdr completion bash)"
	fi
fi
