#!/usr/bin/env bats

load ../test_helper
load ../../lib/composure

function local_setup {
  mkdir -p $BASH_IT
  lib_directory="$(cd "$(dirname "$0")" && pwd)"
  cp -r $lib_directory/../../* $BASH_IT/

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

@test "install: verify that the install script exists" {
  [ -e "$BASH_IT/install.sh" ]
}

@test "install: run the install script silently" {
  skip "Waiting for test to be implemented"
  cd "$BASH_IT"

  ./install.sh --silent

  [ -e "$BASH_IT_TEST_HOME/.bash_profile" ]
}
