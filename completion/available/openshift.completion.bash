# shellcheck shell=bash

# Make sure oc is installed
_bash-it-completion-helper-necessary oc || return

# Don't handle completion if it's already managed
_bash-it-completion-helper-sufficient oc || return

# shellcheck disable=SC1090
source <(oc completion bash)
