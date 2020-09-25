#!/usr/bin/env bash
# Bash completion support for nodenv

if _command_exists nodenv && [[ -r "$(dirname $(readlink -f $(which nodenv)))/../completions/nodenv.bash" ]] ; then
  source "$(dirname $(readlink -f $(which nodenv)))/../completions/nodenv.bash"
fi
