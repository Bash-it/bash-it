#!/usr/bin/env bash

# bash-preexec.sh -- Bash support for ZSH-like 'preexec' and 'precmd' functions.
# https://github.com/rcaloras/bash-preexec
#
#
# 'preexec' functions are executed before each interactive command is
# executed, with the interactive command as its argument. The 'precmd'
# function is executed before each prompt is displayed.
#
# Author: Ryan Caloras (ryan@bashhub.com)
# Forked from Original Author: Glyph Lefkowitz
# Modified by LanikSJ for Bash-it
#
# V0.3.7
#

# General Usage:
#
#  1. Source this file at the end of your bash profile so as not to interfere
#     with anything else that's using PROMPT_COMMAND.
#
#  2. Add any precmd or preexec functions by appending them to their arrays:
#       e.g.
#       precmd_functions+=(my_precmd_function)
#       precmd_functions+=(some_other_precmd_function)
#
#       preexec_functions+=(my_preexec_function)
#
#  3. Consider changing anything using the DEBUG trap or PROMPT_COMMAND
#     to use preexec and precmd instead. Preexisting usages will be
#     preserved, but doing so manually may be less surprising.
#
#  Note: This module requires two Bash features which you must not otherwise be
#  using: the "DEBUG" trap, and the "PROMPT_COMMAND" variable. If you override
#  either of these after bash-preexec has been installed it will most likely break.

# Avoid duplicate inclusion
if [[ "${preexec_imported:-}" == "defined" ]]; then
  return 0
fi
preexec_imported="defined"

# Should be available to each precmd and preexec
# functions, should they want it. $? and $_ are available as $? and $_, but
# $PIPESTATUS is available only in a copy, $BP_PIPESTATUS.
# TODO: Figure out how to restore PIPESTATUS before each precmd or preexec
# function.
preexec_last_ret_value="$?"
BP_PIPESTATUS=("${PIPESTATUS[@]}")
preexec_last_argument_prev_command="$_"

preexec_inside_precmd=0
preexec_inside_preexec=0

# Fails if any of the given variables are readonly
# Reference https://stackoverflow.com/a/4441178
preexec_require_not_readonly() {
  for var; do
    if ! ( unset "$var" 2> /dev/null ); then
      echo "bash-preexec requires write access to ${var}" >&2
      return 1
    fi
  done
}

# Remove ignorespace and or replace ignoreboth from HISTCONTROL
# so we can accurately invoke preexec with a command from our
# history even if it starts with a space.
preexec_adjust_histcontrol() {
  local histcontrol
  histcontrol="${HISTCONTROL//ignorespace}"
  # Replace ignoreboth with ignoredups
  if [[ "$histcontrol" == *"ignoreboth"* ]]; then
    histcontrol="ignoredups:${histcontrol//ignoreboth}"
  fi;
  export HISTCONTROL="$histcontrol"
}

# This variable describes whether we are currently in "interactive mode";
# i.e. whether this shell has just executed a prompt and is waiting for user
# input.  It documents whether the current command invoked by the trace hook is
# run interactively by the user; it's set immediately after the prompt hook,
# and unset as soon as the trace hook is run.
preexec_preexec_interactive_mode=""

preexec_trim_whitespace() {
  local var=$@
  var="${var#"${var%%[![:space:]]*}"}"   # remove leading whitespace characters
  var="${var%"${var##*[![:space:]]}"}"   # remove trailing whitespace characters
  echo -n "$var"
}

# This function is installed as part of the PROMPT_COMMAND;
# It sets a variable to indicate that the prompt was just displayed,
# to allow the DEBUG trap to know that the next command is likely interactive.
preexec_interactive_mode() {
  preexec_preexec_interactive_mode="on";
}


# This function is installed as part of the PROMPT_COMMAND.
# It will invoke any functions defined in the precmd_functions array.
preexec_precmd_invoke_cmd() {
  # Save the returned value from our last command, and from each process in
  # its pipeline. Note: this MUST be the first thing done in this function.
  preexec_last_ret_value="$?" BP_PIPESTATUS=("${PIPESTATUS[@]}")

  # Don't invoke precmds if we are inside an execution of an "original
  # prompt command" by another precmd execution loop. This avoids infinite
  # recursion.
  if (( preexec_inside_precmd > 0 )); then
    return
  fi
  local preexec_inside_precmd=1

  # Invoke every function defined in our function array.
  local precmd_function
  for precmd_function in "${precmd_functions[@]}"; do

    # Only execute this function if it actually exists.
    # Test existence of functions with: declare -[Ff]
    if type -t "$precmd_function" 1>/dev/null; then
      preexec_set_ret_value "$preexec_last_ret_value" "$preexec_last_argument_prev_command"
      # Quote our function invocation to prevent issues with IFS
      "$precmd_function"
    fi
  done
}

# Sets a return value in $?. We may want to get access to the $? variable in our
# precmd functions. This is available for instance in zsh. We can simulate it in bash
# by setting the value here.
preexec_set_ret_value() {
  return ${1:-}
}

preexec_in_prompt_command() {

  local prompt_command_array
  IFS=';' read -ra prompt_command_array <<< "$PROMPT_COMMAND"

  local trimmed_arg
  trimmed_arg=$(preexec_trim_whitespace "${1:-}")

  local command
  for command in "${prompt_command_array[@]:-}"; do
    local trimmed_command
    trimmed_command=$(preexec_trim_whitespace "$command")
    # Only execute each function if it actually exists.
    if [[ "$trimmed_command" == "$trimmed_arg" ]]; then
      return 0
    fi
  done

  return 1
}

# This function is installed as the DEBUG trap.  It is invoked before each
# interactive prompt display.  Its purpose is to inspect the current
# environment to attempt to detect if the current command is being invoked
# interactively, and invoke 'preexec' if so.
preexec_preexec_invoke_exec() {
  # Save the contents of $_ so that it can be restored later on.
  # https://stackoverflow.com/questions/40944532/bash-preserve-in-a-debug-trap#40944702
  preexec_last_argument_prev_command="${1:-}"
  # Don't invoke preexecs if we are inside of another preexec.
  if (( preexec_inside_preexec > 0 )); then
    return
  fi
  local preexec_inside_preexec=1

  # Checks if the file descriptor is not standard out (i.e. '1')
  # preexec_delay_install checks if we're in test. Needed for bats to run.
  # Prevents preexec from being invoked for functions in PS1
  if [[ ! -t 1 && -z "${preexec_delay_install:-}" ]]; then
    return
  fi

  if [[ -n "${COMP_LINE:-}" ]]; then
    # We're in the middle of a completer. This obviously can't be
    # an interactively issued command.
    return
  fi
  if [[ -z "${preexec_preexec_interactive_mode:-}" ]]; then
    # We're doing something related to displaying the prompt.  Let the
    # prompt set the title instead of me.
    return
  else
    # If we're in a subshell, then the prompt won't be re-displayed to put
    # us back into interactive mode, so let's not set the variable back.
    # In other words, if you have a subshell like
    #   (sleep 1; sleep 2)
    # You want to see the 'sleep 2' as a set_command_title as well.
    if [[ 0 -eq "${BASH_SUBSHELL:-}" ]]; then
      preexec_preexec_interactive_mode=""
    fi
  fi

  if  preexec_in_prompt_command "${BASH_COMMAND:-}"; then
    # If we're executing something inside our prompt_command then we don't
    # want to call preexec. Bash prior to 3.1 can't detect this at all :/
    preexec_preexec_interactive_mode=""
    return
  fi

  local this_command
  this_command=$(HISTTIMEFORMAT= builtin history 1 | sed '1 s/^ *[0-9]\+[* ] //')

  # Sanity check to make sure we have something to invoke our function with.
  if [[ -z "$this_command" ]]; then
    return
  fi

  # If none of the previous checks have returned out of this function, then
  # the command is in fact interactive and we should invoke the user's
  # preexec functions.

  # Invoke every function defined in our function array.
  local preexec_function
  local preexec_function_ret_value
  local preexec_ret_value=0
  for preexec_function in "${preexec_functions[@]:-}"; do

    # Only execute each function if it actually exists.
    # Test existence of function with: declare -[fF]
    if type -t "$preexec_function" 1>/dev/null; then
      preexec_set_ret_value ${preexec_last_ret_value:-}
      # Quote our function invocation to prevent issues with IFS
      "$preexec_function" "$this_command"
      preexec_function_ret_value="$?"
      if [[ "$preexec_function_ret_value" != 0 ]]; then
        preexec_ret_value="$preexec_function_ret_value"
      fi
    fi
  done

  # Restore the last argument of the last executed command, and set the return
  # value of the DEBUG trap to be the return code of the last preexec function
  # to return an error.
  # If `extdebug` is enabled a non-zero return value from any preexec function
  # will cause the user's command not to execute.
  # Run `shopt -s extdebug` to enable
  preexec_set_ret_value "$preexec_ret_value" "$preexec_last_argument_prev_command"
}

preexec_install() {
  # Exit if we already have this installed.
  if [[ "${PROMPT_COMMAND:-}" == *"preexec_precmd_invoke_cmd"* ]]; then
    return 1;
  fi

  trap 'preexec_preexec_invoke_exec "$_"' DEBUG

  # Preserve any prior DEBUG trap as a preexec function
  local prior_trap=$(sed "s/[^']*'\(.*\)'[^']*/\1/" <<<"${preexec_trap_string:-}")
  unset preexec_trap_string
  if [[ -n "$prior_trap" ]]; then
    eval 'preexec_original_debug_trap() {
          '"$prior_trap"'
    }'
    preexec_functions+=(preexec_original_debug_trap)
  fi

  # Adjust our HISTCONTROL Variable if needed.
  preexec_adjust_histcontrol


  # Issue #25. Setting debug trap for subshells causes sessions to exit for
  # backgrounded subshell commands (e.g. (pwd)& ). Believe this is a bug in Bash.
  #
  # Disabling this by default. It can be enabled by setting this variable.
  if [[ -n "${preexec_enable_subshells:-}" ]]; then

    # Set so debug trap will work be invoked in subshells.
    set -o functrace > /dev/null 2>&1
    shopt -s extdebug > /dev/null 2>&1
  fi;

  # Install our hooks in PROMPT_COMMAND to allow our trap to know when we've
  # actually entered something.
  PROMPT_COMMAND="preexec_precmd_invoke_cmd; preexec_interactive_mode"

  # Add two functions to our arrays for convenience
  # of definition.
  precmd_functions+=(precmd)
  preexec_functions+=(preexec)

  # Since this function is invoked via PROMPT_COMMAND, re-execute PC now that it's properly set
  eval "$PROMPT_COMMAND"
}

# Sets our trap and preexec_install as part of our PROMPT_COMMAND to install
# after our session has started. This allows bash-preexec to be included
# at any point in our bash profile. Ideally we could set our trap inside
# preexec_install, but if a trap already exists it'll only set locally to
# the function.
preexec_install_after_session_init() {

  # Make sure this is bash that's running this and return otherwise.
  if [[ -z "${BASH_VERSION:-}" ]]; then
    return 1;
  fi

  # bash-preexec needs to modify these variables in order to work correctly
  # if it can't, just stop the installation
  preexec_require_not_readonly PROMPT_COMMAND HISTCONTROL HISTTIMEFORMAT || return

  # If there's an existing PROMPT_COMMAND capture it and convert it into a function
  # So it is preserved and invoked during precmd.
  if [[ -n "$PROMPT_COMMAND" ]]; then
    eval 'preexec_original_prompt_command() {
        '"$PROMPT_COMMAND"'
    }'
    precmd_functions+=(preexec_original_prompt_command)
  fi

  # Installation is finalized in PROMPT_COMMAND, which allows us to override the DEBUG
  # trap. preexec_install sets PROMPT_COMMAND to its final value, so these are only
  # invoked once.
  # It's necessary to clear any existing DEBUG trap in order to set it from the install function.
  # Using \n as it's the most universal delimiter of bash commands
  PROMPT_COMMAND=$'\npreexec_trap_string="$(trap -p DEBUG)"\ntrap DEBUG\npreexec_install\n'
}

# Run our install so long as we're not delaying it.
if [[ -z "$preexec_delay_install" ]]; then
  preexec_install_after_session_init
fi;
