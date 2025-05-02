# shellcheck shell=bash

# Make sure terraform is installed
_bash-it-completion-helper-necessary terraform || return

# Don't handle completion if it's already managed
_bash-it-completion-helper-sufficient terraform || return

# Terraform completes itself
complete -C terraform terraform
