#!/usr/bin/env bash

# npm (Node Package Manager) completion
# https://docs.npmjs.com/cli/completion

if command -v npm &>/dev/null
then
  eval "$(npm completion)"
fi
