#!/usr/bin/env bash

# Load late to make sure `system` completion loads first
# BASH_IT_LOAD_PRIORITY: 375

if [[ "$(uname -s)" != 'Darwin' ]] ; then
  _log_warning "unsupported operating system - only 'Darwin' is supported"
  return 0
fi

# Make sure brew is installed
_command_exists brew || return 0

BREW_PREFIX=${BREW_PREFIX:-$(brew --prefix)}

if [[ -r "$BREW_PREFIX"/etc/bash_completion.d/brew ]] ; then
  source "$BREW_PREFIX"/etc/bash_completion.d/brew

elif [[ -r "$BREW_PREFIX"/Library/Contributions/brew_bash_completion.sh ]] ; then
  source "$BREW_PREFIX"/Library/Contributions/brew_bash_completion.sh

elif [[ -f "$BREW_PREFIX"/completions/bash/brew ]] ; then
  # For the git-clone based installation, see here for more info:
  # https://github.com/Bash-it/bash-it/issues/1458
  # https://docs.brew.sh/Shell-Completion
  source "$BREW_PREFIX"/completions/bash/brew
fi
