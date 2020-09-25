#!/usr/bin/env bash
# Bash completion support for goenv

if _command_exists goenv && [[ -r "$(dirname $(readlink -f $(which goenv)))/../completions/goenv.bash" ]] ; then
  source "$(dirname $(readlink -f $(which goenv)))/../completions/goenv.bash"
fi
