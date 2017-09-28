if which brew >/dev/null 2>&1; then
  BREW_PREFIX=$(brew --prefix)

  if [ -f "$BREW_PREFIX"/etc/bash_completion.d/brew ]; then
    . "$BREW_PREFIX"/etc/bash_completion.d/brew
  fi

  if [ -f "$BREW_PREFIX"/Library/Contributions/brew_bash_completion.sh ]; then
    . "$BREW_PREFIX"/Library/Contributions/brew_bash_completion.sh
  fi
fi
