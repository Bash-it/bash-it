#!/usr/bin/env bash

if _command_exists goenv && [[ -r "$GOENV_ROOT/completions/goenv.bash" ]] ; then
  source "$GOENV_ROOT/completions/goenv.bash"
fi
