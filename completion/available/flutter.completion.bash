# shellcheck shell=bash

# Make sure flutter is installed
_bash-it-completion-helper-necessary flutter || return

# Don't handle completion if it's already managed
_bash-it-completion-helper-sufficient flutter || return

eval "$(flutter bash-completion)"
