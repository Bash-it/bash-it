# shellcheck shell=bash

# Make sure kind is installed
_bash-it-completion-helper-necessary kind || return

# Don't handle completion if it's already managed
_bash-it-completion-helper-sufficient kind || return

eval "$(kind completion bash)"
