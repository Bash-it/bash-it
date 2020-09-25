#!/usr/bin/env bash
# Bash completion support for rbenv

if _command_exists rbenv && [[ -r "$(dirname $(readlink -f $(which rbenv)))/../completions/rbenv.bash" ]] ; then
  source "$(dirname $(readlink -f $(which rbenv)))/../completions/rbenv.bash"
fi
