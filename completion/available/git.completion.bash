if [ $(uname) = "Linux" ] ; then
  if [ -f /etc/bash_completion.d/git-completion.bash ]; then
    . /etc/bash_completion.d/git-completion.bash
  fi

  if [ -f /usr/share/bash-completion/completions/git ]; then
    . /usr/share/bash-completion/completions/git
  fi
fi

if [ $(uname) = "Darwin" ] ; then
  # if brew and git from brew installed
  if which brew >/dev/null 2>&1 && which brew list git >/dev/null 2>&1; then
    BREW_PREFIX=$(brew --prefix)

    if [ -f "$BREW_PREFIX"/etc/bash_completion.d/git-completion.bash ]; then
      . "$BREW_PREFIX"/etc/bash_completion.d/git-completion.bash
    fi

  # Apple git bash completion
  else
    if [ -f /Applications/Xcode.app/Contents/Developer/usr/share/git-core/git-completion.bash ]; then
        . /Applications/Xcode.app/Contents/Developer/usr/share/git-core/git-completion.bash
    fi
  fi

fi
