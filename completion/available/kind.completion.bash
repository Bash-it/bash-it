#!/usr/bin/env bash

if _command_exists kind; then
  eval "$(kind completion bash)"
fi
