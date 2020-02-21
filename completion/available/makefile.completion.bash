#!/usr/bin/env bash
# Bash completion for Makefile

# Loosely adapted from http://stackoverflow.com/a/38415982/1472048

_makecomplete() {
  # https://www.gnu.org/software/make/manual/html_node/Makefile-Names.html
  local files=( $(find . -maxdepth 1 -regextype posix-extended -regex '.*(GNU)?[Mm]akefile$' -printf '%f ') )

  # collect all targets
  local targets=''
  for f in ${files[@]} ; do
    for t in $(grep -oE '^[a-zA-Z0-9_-]+:([^=]|$)' $f | cut -d':' -f1) ; do
      targets+="$t\n"
    done
  done

  # flatten the array for completion
  COMPREPLY=($(compgen -W "$(echo -e "$targets" | head -c -1 | sort -u)" -- ${COMP_WORDS[COMP_CWORD]}))
  return 0
}

complete -o nospace -F _makecomplete make
complete -o nospace -F _makecomplete gnumake
