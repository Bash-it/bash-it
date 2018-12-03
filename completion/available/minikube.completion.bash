#!/usr/bin/env bash

# minikube (Local Kubernetes) completion

if command -v minikube &>/dev/null
then
  eval "$(minikube completion bash)"
fi
