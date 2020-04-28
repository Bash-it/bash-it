#!/usr/bin/env bash
cite "about-completion"
about-completion "GitHub CLI completion"

if command -v which gh >/dev/null 2>&1; then
  if command -v which brew >/dev/null 2>&1; then
    BREW_PREFIX=$(brew --prefix)

    if [ -f "$BREW_PREFIX"/etc/bash_completion.d/gh.sh ]; then
      . "$BREW_PREFIX"/etc/bash_completion.d/gh.sh
    fi

  else
    eval "$(gh completion --shell=bash)"
  fi
fi
