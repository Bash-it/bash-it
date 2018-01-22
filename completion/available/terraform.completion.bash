#!/usr/bin/env bash
# Bash Terraform completion
# Source: https://gist.github.com/cornfeedhobo/8bc08747ec3add1fc5adb2edb7cd68d3

_terraform() {
  local cur prev words cword opts
  _get_comp_words_by_ref -n : cur prev words cword
  COMPREPLY=()
  opts=""

  if [[ ${cur} == -* ]] ; then
    compopt -o nospace
  fi

  if [[ ${cword} -eq 1 ]] ; then
    if [[ ${cur} == -* ]] ; then
      opts="--help --version"
    else
      opts="$(terraform --help | grep -vE '(usage|Available|^$)' | awk '{print $1}')"
    fi
  fi

  if [[ ${cword} -gt 1 ]] ; then
    if [[ ${cword} -eq 2 && ${prev} == '--help' ]] ; then
      opts="$(terraform --help | grep -vE '(usage|Available|^$)' | awk '{print $1}')"
    else
      opts="$(terraform --help "${words[1]}" | grep '^ *-[a-z]' | awk '{print $1}' | awk -F '=' '{if ($0 ~ /=/) {print $1"="} else {print $1" "}}')"
    fi
  fi

  COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
  return 0
}

complete -F _terraform terraform
