#!/usr/bin/env bash

export BASH_IT_LOG_LEVEL_ERROR=1
export BASH_IT_LOG_LEVEL_WARNING=2
export BASH_IT_LOG_LEVEL_ALL=3

function _has_colors()
{
  # Check that stdout is a terminal
  test -t 1 || return 1

  ncolors=$(tput colors)
  test -n "$ncolors" && test "$ncolors" -ge 8 || return 1
  return 0
}

function _log_general()
{
  about 'Internal function used for logging, uses BASH_IT_LOG_PREFIX as a prefix'
  param '1: color of the message'
  param '2: log level to print before the prefix'
  param '3: message to log'
  group 'log'

  message=$2${BASH_IT_LOG_PREFIX}$3
  _has_colors && echo -e "$1${message}${echo_normal}" || echo -e "${message}"
}

function _log_debug()
{
  about 'log a debug message by echoing to the screen. needs BASH_IT_LOG_LEVEL >= BASH_IT_LOG_LEVEL_ALL'
  param '1: message to log'
  example '$ _log_debug "Loading plugin git..."'
  group 'log'

  [[ "$BASH_IT_LOG_LEVEL" -ge $BASH_IT_LOG_LEVEL_ALL ]] || return 0
  _log_general "${echo_green}" "DEBUG: " "$1"
}

function _log_warning()
{
  about 'log a message by echoing to the screen. needs BASH_IT_LOG_LEVEL >= BASH_IT_LOG_LEVEL_WARNING'
  param '1: message to log'
  example '$ _log_warning "git binary not found, disabling git plugin..."'
  group 'log'

  [[ "$BASH_IT_LOG_LEVEL" -ge $BASH_IT_LOG_LEVEL_WARNING ]] || return 0
  _log_general "${echo_yellow}" " WARN: " "$1"
}

function _log_error()
{
  about 'log a message by echoing to the screen. needs BASH_IT_LOG_LEVEL >= BASH_IT_LOG_LEVEL_ERROR'
  param '1: message to log'
  example '$ _log_error "Failed to load git plugin..."'
  group 'log'

  [[ "$BASH_IT_LOG_LEVEL" -ge $BASH_IT_LOG_LEVEL_ERROR ]] || return 0
  _log_general "${echo_red}" "ERROR: " "$1"
}
