if which brew >/dev/null 2>&1; then
  if [ -f `brew --prefix`/etc/bash_completion.d/brew ]; then
      . `brew --prefix`/etc/bash_completion.d/brew
  fi
fi
