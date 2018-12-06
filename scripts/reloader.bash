#!/bin/bash
pushd "${BASH_IT}" >/dev/null || exit 1

# TODO: Add debugging output

if [ "$1" != "false" ] && [ -d "./enabled" ]; then
  for _bash_it_config_file in $(sort <(compgen -G "./enabled/*${1}.bash")); do
    if [ -e "${_bash_it_config_file}" ]; then
      # shellcheck source=/dev/null
      source $_bash_it_config_file
    else
      echo "Unable to read ${_bash_it_config_file}" > /dev/stderr
    fi
  done
fi


if [ ! -z "${2}" ] && [ -d "${2}/enabled" ]; then
  # TODO: We should warn users they're using legacy enabling
  for _bash_it_config_file in $(sort <(compgen -G "./${2}/enabled/*.bash")); do
    if [ -e "$_bash_it_config_file" ]; then
      # shellcheck source=/dev/null
      source "$_bash_it_config_file"
    else
      # TODO Display an error?
      echo "Unable to locate ${_bash_it_config_file}" > /dev/null
    fi
  done
fi

unset _bash_it_config_file
popd >/dev/null || exit 1
