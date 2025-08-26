# shellcheck shell=bash
about-completion "terraform/tofu completion"

# Note, this is not using the _bash-it-completion-helper-necessary function
# because it's a multiple choice case, and will therefore produce more
# sensible log messages.

# Check if at least one of the binaries is available (OR logic)
if ! _binary_exists terraform && ! _binary_exists tofu; then
	_log_warning "Without 'terraform' or 'tofu' installed, this completion won't be too useful."
	return 1
fi

# Handle terraform completion if available and not already managed
if _binary_exists terraform; then
	_bash-it-completion-helper-sufficient terraform || {
		# Terraform completes itself
		complete -C terraform terraform
	}
fi

# Handle tofu completion if available and not already managed
if _binary_exists tofu; then
	_bash-it-completion-helper-sufficient tofu || {
		# OpenTofu completes itself
		complete -C tofu tofu
	}
fi
