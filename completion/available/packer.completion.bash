# shellcheck shell=bash
about-completion "packer completion"

# Make sure packer is installed
_bash-it-completion-helper-necessary packer || return

# Don't handle completion if it's already managed
_bash-it-completion-helper-sufficient packer || return

complete -C packer packer
