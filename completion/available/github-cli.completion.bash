#!/usr/bin/env bash
cite "about-completion"
about-completion "GitHub CLI completion"

if _binary_exists gh; then
  if _command_exists brew; then
    _log_warning "You don't need github-cli completion enabled if you have system completion enabled"
  fi
  eval "$(gh completion --shell=bash)"
fi
