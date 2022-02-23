# shellcheck shell=bash
about-completion "jungle(AWS cli tool) completion"

# Make sure jungle is installed
_bash-it-completion-helper-necessary jungle || return

# Don't handle completion if it's already managed
_bash-it-completion-helper-sufficient jungle || return

eval "$(_JUNGLE_COMPLETE=source jungle)"
