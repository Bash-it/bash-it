if which crystal >/dev/null 2>&1; then

  if which brew >/dev/null 2>&1; then
    BREW_PREFIX=$(brew --prefix)

    if [ -f "$BREW_PREFIX"/etc/bash_completion.d/crystal ]; then
      . "$BREW_PREFIX"/etc/bash_completion.d/crystal
    fi
  fi

fi
