# shellcheck shell=bash
about-completion "vault completion"

# Make sure vault is installed
_bash-it-completion-helper-necessary vault || return

# Don't handle completion if it's already managed
_bash-it-completion-helper-sufficient vault || return

complete -C vault vault
