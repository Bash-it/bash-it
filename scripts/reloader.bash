#!/bin/bash
pushd "${BASH_IT}" >/dev/null || exit 1

# TODO: Add debugging output

if [ "$1" != "skip" ] && [ -d "./enabled" ]; then
  _bash_it_config_type=""
  if [[ "${1}" =~ ^(alias|completion|plugin)$ ]]; then
    _bash_it_config_type=$1
  fi
  for _bash_it_config_file in $(sort <(compgen -G "./enabled/*${_bash_it_config_type}.bash")); do
    if [ -e "${_bash_it_config_file}" ]; then
      # shellcheck source=/dev/null
      source $_bash_it_config_file
    else
      echo "Unable to read ${_bash_it_config_file}" > /dev/stderr
    fi
  done
fi


if [ ! -z "${2}" ] && [[ "${2}" =~ ^(aliases|completion|plugins)$ ]] && [ -d "${2}/enabled" ]; then
  # TODO: We should warn users they're using legacy enabling
  for _bash_it_config_file in $(sort <(compgen -G "./${2}/enabled/*.bash")); do
    if [ -e "$_bash_it_config_file" ]; then
      # shellcheck source=/dev/null
      source "$_bash_it_config_file"
    else
      echo "Unable to locate ${_bash_it_config_file}" > /dev/stderr
    fi
  done
fi

unset _bash_it_config_file
unset _bash_it_config_type
popd >/dev/null || exit 1
