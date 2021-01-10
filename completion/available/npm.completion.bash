#!/usr/bin/env bash

# npm (Node Package Manager) completion
# https://docs.npmjs.com/cli/completion

if _command_exists npm
then
    eval "$(npm completion)"
fi
