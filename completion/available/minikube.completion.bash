# shellcheck shell=bash
# minikube (Local Kubernetes) completion

if _command_exists minikube; then
	eval "$(minikube completion bash)"
fi
