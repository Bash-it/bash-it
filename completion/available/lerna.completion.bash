#!/bin/bash
# Usage:
#
# To enable bash <tab> completion for lerna, add the following line (minus the
# leading #, which is the bash comment character) to your ~/.bashrc file:
#
# eval "$(lerna --completion=bash)"
# Enable bash autocompletion.
function _lerna_completions() {
  # The currently-being-completed word.
  local cur compls

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
