# shellcheck shell=bash
cite "about-completion"
about-completion "helm (Kubernetes Package Manager) completion"

if _command_exists helm; then
	eval "$(helm completion bash)"
fi
