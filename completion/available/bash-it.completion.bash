#!/usr/bin/env bash

_bash-it-comp-enable-disable()
{
  local enable_disable_args="alias completion plugin"
  COMPREPLY=( $(compgen -W "${enable_disable_args}" -- ${cur}) )
}

_bash-it-comp-list-available-not-enabled()
{
  subdirectory="$1"

  local available_things

  available_things=$(for f in `compgen -G "${BASH_IT}/$subdirectory/available/*.bash" | sort -d`;
    do
      file_entity=$(basename $f)

      typeset enabled_component=$(command ls "${BASH_IT}/$subdirectory/enabled/"{[0-9]*$BASH_IT_LOAD_PRIORITY_SEPARATOR$file_entity,$file_entity} 2>/dev/null | head -1)
      typeset enabled_component_global=$(command ls "${BASH_IT}/enabled/"[0-9]*$BASH_IT_LOAD_PRIORITY_SEPARATOR$file_entity 2>/dev/null | head -1)

      if [ -z "$enabled_component" ] && [ -z "$enabled_component_global" ]
      then
        basename $f | sed -e 's/\(.*\)\..*\.bash/\1/g'
      fi
    done)

  COMPREPLY=( $(compgen -W "all ${available_things}" -- ${cur}) )
}

_bash-it-comp-list-enabled()
{
  local subdirectory="$1"
  local suffix enabled_things

  suffix=$(echo "$subdirectory" | sed -e 's/plugins/plugin/g')

  enabled_things=$(for f in `sort -d <(compgen -G "${BASH_IT}/$subdirectory/enabled/*.${suffix}.bash") <(compgen -G "${BASH_IT}/enabled/*.${suffix}.bash")`;
    do
      basename $f | sed -e 's/\(.*\)\..*\.bash/\1/g' | sed -e "s/^[0-9]*---//g"
    done)

  COMPREPLY=( $(compgen -W "all ${enabled_things}" -- ${cur}) )
}

_bash-it-comp-list-available()
{
  subdirectory="$1"

  local enabled_things

  enabled_things=$(for f in `compgen -G "${BASH_IT}/$subdirectory/available/*.bash" | sort -d`;
    do
      basename $f | sed -e 's/\(.*\)\..*\.bash/\1/g'
    done)

  COMPREPLY=( $(compgen -W "${enabled_things}" -- ${cur}) )
}

_bash-it-comp()
{
  local cur prev opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  chose_opt="${COMP_WORDS[1]}"
  file_type="${COMP_WORDS[2]}"
  opts="disable enable help migrate search show update version"
  case "${chose_opt}" in
    show)
      local show_args="aliases completions plugins"
      COMPREPLY=( $(compgen -W "${show_args}" -- ${cur}) )
      return 0
      ;;
    help)
      if [ x"${prev}" == x"aliases" ]; then
        _bash-it-comp-list-available aliases
        return 0
      else
        local help_args="aliases completions migrate plugins update"
        COMPREPLY=( $(compgen -W "${help_args}" -- ${cur}) )
        return 0
      fi
      ;;
    update | search | migrate | version)
      return 0
      ;;
    enable | disable)
      if [ x"${chose_opt}" == x"enable" ];then
        suffix="available-not-enabled"
      else
        suffix="enabled"
      fi
      case "${file_type}" in
        alias)
            _bash-it-comp-list-${suffix} aliases
            return 0
            ;;
        plugin)
            _bash-it-comp-list-${suffix} plugins
            return 0
            ;;
        completion)
            _bash-it-comp-list-${suffix} completion
            return 0
            ;;
        *)
            _bash-it-comp-enable-disable
            return 0
            ;;
      esac
      ;;
  esac

  COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )

  return 0
}

# Activate completion for bash-it and its common misspellings
complete -F _bash-it-comp bash-it
complete -F _bash-it-comp bash-ti
complete -F _bash-it-comp shit
complete -F _bash-it-comp bashit
complete -F _bash-it-comp batshit
complete -F _bash-it-comp bash_it
