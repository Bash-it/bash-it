#!/usr/bin/env bash
# Bash completion support for pyenv

if _command_exists pyenv && [[ -r "$(dirname $(readlink -f $(which pyenv)))/../completions/pyenv.bash" ]] ; then
  source "$(dirname $(readlink -f $(which pyenv)))/../completions/pyenv.bash"
fi
