#!/usr/bin/env bash

# helm (Kubernetes Package Manager) completion

if command -v helm &>/dev/null
then
  eval "$(helm completion bash)"
fi
