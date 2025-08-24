# shellcheck shell=bash
about-completion "kubectl (Kubernetes CLI) completion"

# Make sure kubectl is installed
_bash-it-completion-helper-necessary kubectl || return

# Don't handle completion if it's already managed
_bash-it-completion-helper-sufficient kubectl || return

eval "$(kubectl completion bash)"
