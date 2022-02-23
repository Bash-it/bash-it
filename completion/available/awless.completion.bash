# shellcheck shell=bash

# Make sure awless is installed
_bash-it-completion-helper-necessary awless || return

# Don't handle completion if it's already managed
_bash-it-completion-helper-sufficient awless || return

# shellcheck disable=SC1090
source <(awless completion bash)
