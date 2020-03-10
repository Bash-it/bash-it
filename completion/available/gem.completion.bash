#!/usr/bin/env bash
# Completion for gem

_installcomp() {
  if [ -z "$REMOTE_GEMS" ]
  then
    REMOTE_GEMS=( $(gem list --remote --no-versions | tr '\n' ' ') )
  fi

  local cur=${COMP_WORDS[COMP_CWORD]}
  COMPREPLY=( $(compgen -W "${REMOTE_GEMS[*]}" -- $cur) )
}

_uninstallcomp() {
  if [ -z "$LOCAL_GEMS" ]
  then
    LOCAL_GEMS=( $(gem list --no-versions | sed 's/\*\*\* LOCAL GEMS \*\*\*//' | tr '\n' ' ') )
  fi

  local cur=${COMP_WORDS[COMP_CWORD]}
  COMPREPLY=( $(compgen -W "${LOCAL_GEMS[*]}" -- $cur) )
}

_gem() {
  local cur=${COMP_WORDS[COMP_CWORD]}
  local prev=${COMP_WORDS[COMP_CWORD-1]}
  case $prev in
    install)
      _installcomp
      return 0
      ;;
    uninstall)
      _uninstallcomp
      return 0
      ;;
  esac
  local commands=(build cert check cleanup contents dependency environment fetch generate_index help install list lock outdated owner pristine push query rdoc search server sources specification stale uninstall unpack update which)
  COMPREPLY=( $(compgen -W "${commands[*]}" -- $cur) )
}

complete -F _gem gem
