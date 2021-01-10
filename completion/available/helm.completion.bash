#!/usr/bin/env bash

# helm (Kubernetes Package Manager) completion

if _command_exists helm
then
    eval "$(helm completion bash)"
fi
