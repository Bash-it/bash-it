# shellcheck shell=bash
about-completion "GitHub CLI completion"

# Make sure gh is installed
_bash-it-completion-helper-necessary gh || return

# Don't handle completion if it's already managed
_bash-it-completion-helper-sufficient gh || return

eval "$(gh completion --shell=bash)"
