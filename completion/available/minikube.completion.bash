# shellcheck shell=bash
about-completion "minikube (Local Kubernetes) completion"

# Make sure minikube is installed
_bash-it-completion-helper-necessary minikube || return

# Don't handle completion if it's already managed
_bash-it-completion-helper-sufficient minikube || return

eval "$(minikube completion bash)"
