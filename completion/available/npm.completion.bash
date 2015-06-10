#!/usr/bin/env bash

# npm (Node Package Manager) completion

if command -v npm &>/dev/null
then
  eval "$(npm completion)"
fi
