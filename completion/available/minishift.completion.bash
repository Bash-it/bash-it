# shellcheck shell=bash

# Make sure minishift is installed
_bash-it-completion-helper-necessary minishift || return

# Don't handle completion if it's already managed
_bash-it-completion-helper-sufficient minishift || return

# shellcheck disable=SC1090
source <(minishift completion bash)
