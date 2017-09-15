#!/usr/bin/env bats

load ../test_helper
load ../../lib/composure
load ../../completion/available/bash-it.completion

function local_setup {
  mkdir -p "$BASH_IT"
  lib_directory="$(cd "$(dirname "$0")" && pwd)"
  # Use rsync to copy Bash-it to the temp folder
  # rsync is faster than cp, since we can exclude the large ".git" folder
  rsync -qavrKL -d --delete-excluded --exclude=.git $lib_directory/../.. "$BASH_IT"

  rm -rf "$BASH_IT"/enabled
  rm -rf "$BASH_IT"/aliases/enabled
  rm -rf "$BASH_IT"/completion/enabled
  rm -rf "$BASH_IT"/plugins/enabled

  # Don't pollute the user's actual $HOME directory
  # Use a test home directory instead
  export BASH_IT_TEST_CURRENT_HOME="${HOME}"
  export BASH_IT_TEST_HOME="$(cd "${BASH_IT}/.." && pwd)/BASH_IT_TEST_HOME"
  mkdir -p "${BASH_IT_TEST_HOME}"
  export HOME="${BASH_IT_TEST_HOME}"
}

function local_teardown {
  export HOME="${BASH_IT_TEST_CURRENT_HOME}"

  rm -rf "${BASH_IT_TEST_HOME}"

  assert_equal "${BASH_IT_TEST_CURRENT_HOME}" "${HOME}"
}

@test "completion bash-it: ensure that the _bash-it-comp function is available" {
  type -a _bash-it-comp &> /dev/null
  assert_success
}

@test "completion bash-it: provide the atom aliases when not enabled" {
  COMP_WORDS=(bash-it enable alias ato)

  COMP_CWORD=3

  COMP_LINE='bash-it enable alias ato'

  COMP_POINT=${#COMP_LINE}

  _bash-it-comp

  echo "${COMPREPLY[@]}"
  all_results="${COMPREPLY[@]}"

  assert_equal "atom" "$all_results"
}

@test "completion bash-it: provide the a* aliases when not enabled" {
  COMP_WORDS=(bash-it enable alias a)

  COMP_CWORD=3

  COMP_LINE='bash-it enable alias a'

  COMP_POINT=${#COMP_LINE}

  _bash-it-comp

  echo "${COMPREPLY[@]}"
  all_results="${COMPREPLY[@]}"

  assert_equal "all ag ansible apt atom" "$all_results"
}
