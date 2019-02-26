#!/usr/bin/env bash

# https://github.com/koalaman/shellcheck/wiki/Sc2154
# shellcheck disable=SC2154

function _user-prompt() {
  local -r user='\\u'

  if [[ "${EUID}" -eq 0 ]]; then
    # Privileged users:
    local -r user_color="${bold_red}"
  else
    # Standard users:
    local -r user_color="${bold_green}"
  fi

  # Print the current user's name (colored according to their current EUID):
  echo -e "${user_color}${user}${normal}"
}

function _host-prompt() {
  local -r host='\\h'

  # Check whether or not $SSH_TTY is set:
  if [[ -z "${SSH_TTY}" ]]; then
    # For local hosts, set the host's prompt color to blue:
    local -r host_color="${bold_blue}"
  else
    # For remote hosts, set the host's prompt color to red:
    local -r host_color="${bold_red}"
  fi

  # Print the current hostname (colored according to $SSH_TTY's status):
  echo -e "${host_color}${host}${normal}"
}

function _user-at-host-prompt() {
  # Concatenate the user and host prompts into: user@host:
  echo -e "$(_user-prompt)${bold_white}@$(_host-prompt)"
}

function _exit-status-prompt() {
  local -r prompt_string="${1}"
  local -r exit_status="${2}"

  # Check the exit status of the last command captured by $exit_status:
  if [[ "${exit_status}" -eq 0 ]]; then
    # For commands that return an exit status of zero, set the exit status's
    # notifier to green:
    local -r exit_status_color="${bold_green}"
  else
    # For commands that return a non-zero exit status, set the exit status's
    # notifier to red:
    local -r exit_status_color="${bold_red}"
  fi

  echo -ne "${exit_status_color}" 
  if [[ "${prompt_string}" -eq 1 ]]; then
    # $PS1:
    echo -e " +${normal} "
  elif [[ "${prompt_string}" -eq 2 ]]; then
    # $PS2:
    echo -e " |${normal} "
  else
    # Default:
    echo -e " ?${normal} "
  fi
}

function _ps1() {
  local -r time='\\t'

  echo -ne "${bold_white}${time} "
  echo -ne "$(_user-at-host-prompt)"
  echo -e "${bold_white}:${normal}${PWD}"
  echo -e "$(_exit-status-prompt 1 "${exit_status}")"
}

function _ps2() {
  echo -e "$(_exit-status-prompt 2 "${exit_status}")"
}

function prompt_command() {
  # Capture the exit status of the last command:
  local -r exit_status="${?}"

  # Build the $PS1 prompt:
  PS1="$(_ps1)"

  # Build the $PS2 prompt:
  PS2="$(_ps2)"
}

safe_append_prompt_command prompt_command

# vim: sw=2 ts=2 et:
