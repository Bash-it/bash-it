#!/usr/bin/env bash

# kubectl (Kubernetes CLI) completion

if _command_exists kubectl
then
    eval "$(kubectl completion bash)"
fi
