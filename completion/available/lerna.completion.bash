#!/bin/bash
# Lerna autocompletion.
function _lerna_completions() {
  local cur compls

  # The currently-being-completed word.
  cur="${COMP_WORDS[COMP_CWORD]}"

  # Options
  compls="add bootstrap changed clean create diff exec \
          import init link list publish run version    \
           --loglevel --concurrency --reject-cycles    \
           --progress --sort --no-sort --help          \
           --version"

  # Tell complete what stuff to show.
  COMPREPLY=($(compgen -W "$compls" -- "$cur"))
}
complete -o default -F _lerna_completions lerna
