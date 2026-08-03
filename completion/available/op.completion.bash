# shellcheck shell=bash
about-completion "1Password CLI tab completion"

if ! _binary_exists op; then
	_log_error "op not found in PATH — completion not loaded. (${BASH_SOURCE[0]})"
	return 1
else
	if ! _bash-it-completion-helper-sufficient op; then
		_log_warning "The completion is set for 'op' externally. Activation will be skipped. (${BASH_SOURCE[0]})"
	else
		eval "$(op completion bash)"
	fi
fi
