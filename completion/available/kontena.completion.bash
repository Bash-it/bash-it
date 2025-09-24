# shellcheck shell=bash

# Make sure kontena is installed
_bash-it-completion-helper-necessary kontena || return

# Don't handle completion if it's already managed
_bash-it-completion-helper-sufficient kontena || return

# shellcheck disable=SC1090
source "$(kontena whoami --bash-completion-path)"
