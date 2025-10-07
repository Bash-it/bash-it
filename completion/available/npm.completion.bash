# shellcheck shell=bash
about-completion "npm (Node Package Manager) completion"

# Make sure npm is installed
_bash-it-completion-helper-necessary npm || return

# Don't handle completion if it's already managed
_bash-it-completion-helper-sufficient npm || return

eval "$(npm completion)"
