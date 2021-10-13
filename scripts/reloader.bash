#!/bin/bash
BASH_IT_LOG_PREFIX="core: reloader: "

if [[ "$1" != "skip" ]] && [[ -d "$BASH_IT/enabled" ]]; then
  _bash_it_config_type=""

  case $1 in
    alias|completion|plugin)
      _bash_it_config_type=$1
      _log_debug "Loading enabled $1 components..." ;;
    ''|*)
      _log_debug "Loading all enabled components..." ;;
  esac

  for _bash_it_config_file in $(sort <(compgen -G "$BASH_IT/enabled/*${_bash_it_config_type}.bash")); do
    if [ -e "${_bash_it_config_file}" ]; then
      _bash-it-log-prefix-by-path "${_bash_it_config_file}"
      _log_debug "Loading component..."
      # shellcheck source=/dev/null
      source $_bash_it_config_file
    else
      echo "Unable to read ${_bash_it_config_file}" > /dev/stderr
    fi
  done
fi

if [[ -n "${2}" ]] && [[ -d "$BASH_IT/${2}/enabled" ]]; then
  case $2 in
    aliases|completion|plugins)
      _log_warning "Using legacy enabling for $2, please update your bash-it version and migrate"
      for _bash_it_config_file in $(sort <(compgen -G "$BASH_IT/${2}/enabled/*.bash")); do
        if [[ -e "$_bash_it_config_file" ]]; then
          _bash-it-log-prefix-by-path "${_bash_it_config_file}"
          _log_debug "Loading component..."
          # shellcheck source=/dev/null
          source "$_bash_it_config_file"
        else
          echo "Unable to locate ${_bash_it_config_file}" > /dev/stderr
        fi
      done ;;
  esac
fi

unset _bash_it_config_file
unset _bash_it_config_type
