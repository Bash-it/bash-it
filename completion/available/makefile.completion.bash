#!/usr/bin/env bash
# Bash completion for Makefile

# Loosely adapted from http://stackoverflow.com/a/38415982/1472048

_makecomplete() {
  # https://www.gnu.org/software/make/manual/html_node/Makefile-Names.html
  local files=()
  while IFS='' read -r line; do
    files+=("$line")
  done < <(find . -maxdepth 1 -regextype posix-extended -regex '.*(GNU)?[Mm]akefile$' -printf '%f\n')

  # collect all targets
  local targets=()
  for f in "${files[@]}" ; do
    while IFS='' read -r line ; do
      targets+=("$line")
    done < <(grep -oE '^[a-zA-Z0-9_-]+:([^=]|$)' "$f" | cut -d':' -f1)
  done

  # flatten the array for completion
  COMPREPLY=()
  while IFS='' read -r line ; do
    COMPREPLY+=("$line")
  done < <(compgen -W "$(tr ' ' '\n' <<<"${targets[@]}" | sort -u)" -- "${COMP_WORDS[COMP_CWORD]}")
  return 0
}

complete -o nospace -F _makecomplete make
complete -o nospace -F _makecomplete gnumake
