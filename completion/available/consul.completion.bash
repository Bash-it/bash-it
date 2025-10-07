# shellcheck shell=bash
about-completion "Hashicorp consul completion"

# Make sure consul is installed
_bash-it-completion-helper-necessary consul || return

# Don't handle completion if it's already managed
_bash-it-completion-helper-sufficient consul || return

complete -C consul consul
