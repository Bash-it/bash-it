#!/usr/bin/env bats

load ../test_helper
load ../../lib/composure

# Determine which config file to use based on OS.
case $OSTYPE in
  darwin*)
    export BASH_IT_CONFIG_FILE=.bash_profile
    ;;
  *)
    export BASH_IT_CONFIG_FILE=.bashrc
    ;;
esac

function local_setup {
  mkdir -p "$BASH_IT"
  lib_directory="$(cd "$(dirname "$0")" && pwd)"
  # Use rsync to copy Bash-it to the temp folder
  # rsync is faster than cp, since we can exclude the large ".git" folder
  rsync -qavrKL -d --delete-excluded --exclude=.git $lib_directory/../../.. "$BASH_IT"

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

@test "install: verify that the install script exists" {
  assert_file_exist "$BASH_IT/install.sh"
}

@test "install: run the install script silently" {
  cd "$BASH_IT"

  ./install.sh --silent

  assert_file_exist "$BASH_IT_TEST_HOME/$BASH_IT_CONFIG_FILE"

  assert_link_exist "$BASH_IT/enabled/150---general.aliases.bash"
  assert_link_exist "$BASH_IT/enabled/250---base.plugin.bash"
  assert_link_exist "$BASH_IT/enabled/365---alias-completion.plugin.bash"
  assert_link_exist "$BASH_IT/enabled/350---bash-it.completion.bash"
  assert_link_exist "$BASH_IT/enabled/350---system.completion.bash"
}

@test "install: verify that a backup file is created" {
  cd "$BASH_IT"

  touch "$BASH_IT_TEST_HOME/$BASH_IT_CONFIG_FILE"
  echo "test file content" > "$BASH_IT_TEST_HOME/$BASH_IT_CONFIG_FILE"
  local md5_orig=$(md5sum "$BASH_IT_TEST_HOME/$BASH_IT_CONFIG_FILE" | awk '{print $1}')

  ./install.sh --silent

  assert_file_exist "$BASH_IT_TEST_HOME/$BASH_IT_CONFIG_FILE"
  assert_file_exist "$BASH_IT_TEST_HOME/$BASH_IT_CONFIG_FILE.bak"

  local md5_bak=$(md5sum "$BASH_IT_TEST_HOME/$BASH_IT_CONFIG_FILE.bak" | awk '{print $1}')

  assert_equal "$md5_orig" "$md5_bak"
}

@test "install: verify that silent and interactive can not be used at the same time" {
  cd "$BASH_IT"

  run ./install.sh --silent --interactive

  assert_failure
}
