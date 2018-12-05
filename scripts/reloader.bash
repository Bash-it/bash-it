#!/bin/bash
pushd "${BASH_IT}" >/dev/null

# TODO: Add debugging output

if [ "$1" != "false" ] && [ -d "./enabled" ]; then
  for _bash_it_config_file in $(ls ./enabled/*${1}.bash 2>/dev/null); do
    if [ -e "${_bash_it_config_file}" ]; then
      source $_bash_it_config_file
    else
      echo "Unable to read ${_bash_it_config_file}" > /dev/stderr
    fi
  done
fi


if [ ! -z "${2}" ] && [ -d "${2}/enabled" ]; then
  # TODO: We should warn users they're using legacy enabling
  for _bash_it_config_file in $(ls ./${2}/enabled/*.bash 2>/dev/null); do
    if [ -e "$_bash_it_config_file" ]; then
      source "$_bash_it_config_file"
    else
      # TODO Display an error?
      echo "Unable to locate ${_bash_it_config_file}" > /dev/null
    fi
  done
fi

unset _bash_it_config_file
popd >/dev/null
