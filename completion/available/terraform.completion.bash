# shellcheck shell=bash

# Make sure terraform is installed
_command_exists terraform || return

# Don't handle completion if it's already managed
complete -p terraform &> /dev/null && return

# Terraform completes itself
complete -C terraform terraform
