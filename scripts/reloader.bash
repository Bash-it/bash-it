#!/bin/bash
BASH_IT_LOG_PREFIX="core: reloader: "
pushd "${BASH_IT}" >/dev/null || exit 1

function _set-prefix-based-on-path()
{
  filename=$(_bash-it-get-component-name-from-path "$1")
  extension=$(_bash-it-get-component-type-from-path "$1")
  BASH_IT_LOG_PREFIX="$extension: $filename: "
}

if [ "$1" != "skip" ] && [ -d "./enabled" ]; then
  _bash_it_config_type=""
  if [[ "${1}" =~ ^(alias|completion|plugin)$ ]]; then
    _bash_it_config_type=$1
    _log_debug "Loading enabled $1 components..."
  else
    _log_debug "Loading all enabled components..."
  fi
  for _bash_it_config_file in $(sort <(compgen -G "./enabled/*${_bash_it_config_type}.bash")); do
    if [ -e "${_bash_it_config_file}" ]; then
      _set-prefix-based-on-path "${_bash_it_config_file}"
      _log_debug "Loading component..."
      # shellcheck source=/dev/null
      source $_bash_it_config_file
    else
      echo "Unable to read ${_bash_it_config_file}" > /dev/stderr
    fi
  done
fi


if [ ! -z "${2}" ] && [[ "${2}" =~ ^(aliases|completion|plugins)$ ]] && [ -d "${2}/enabled" ]; then
  _log_warning "Using legacy enabling for $2, please update your bash-it version and migrate"
  for _bash_it_config_file in $(sort <(compgen -G "./${2}/enabled/*.bash")); do
    if [ -e "$_bash_it_config_file" ]; then
      _set-prefix-based-on-path "${_bash_it_config_file}"
      _log_debug "Loading component..."
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
