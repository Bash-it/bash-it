# shellcheck shell=bash
cite "about-completion"
about-completion "kubectl (Kubernetes CLI) completion"

if _binary_exists kubectl; then
	eval "$(kubectl completion bash)"
fi
