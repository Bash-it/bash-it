#!/usr/bin/env bash
# Bash completion support for jenv

if _command_exists jenv && [[ -r "$(dirname $(readlink -f $(which jenv)))/../completions/jenv.bash" ]] ; then
  source "$(dirname $(readlink -f $(which jenv)))/../completions/jenv.bash"
fi
