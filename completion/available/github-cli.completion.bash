#!/usr/bin/env bash
cite "about-completion"
about-completion "GitHub CLI completion"

if _command_exists gh; then
  if _command_exists brew; then
    echo "You don't need github-cli completion enabled if you have system completion enabled"
  fi
  eval "$(gh completion --shell=bash)"
fi
