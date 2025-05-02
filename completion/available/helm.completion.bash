# shellcheck shell=bash
about-completion "helm (Kubernetes Package Manager) completion"

# Make sure helm is installed
_bash-it-completion-helper-necessary helm || return

# Don't handle completion if it's already managed
_bash-it-completion-helper-sufficient helm || return

eval "$(helm completion bash)"
