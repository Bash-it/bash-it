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
  setup_test_fixture
}

@test "uninstall: verify that the uninstall script exists" {
  assert_file_exist "$BASH_IT/uninstall.sh"
}

@test "uninstall: run the uninstall script with an existing backup file" {
  cd "$BASH_IT"

  echo "test file content for backup" > "$BASH_IT_TEST_HOME/$BASH_IT_CONFIG_FILE.bak"
  echo "test file content for original file" > "$BASH_IT_TEST_HOME/$BASH_IT_CONFIG_FILE"
  local md5_bak=$(md5sum "$BASH_IT_TEST_HOME/$BASH_IT_CONFIG_FILE.bak" | awk '{print $1}')

  ./uninstall.sh

  assert_success

  assert_file_not_exist "$BASH_IT_TEST_HOME/$BASH_IT_CONFIG_FILE.uninstall"
  assert_file_not_exist "$BASH_IT_TEST_HOME/$BASH_IT_CONFIG_FILE.bak"
  assert_file_exist "$BASH_IT_TEST_HOME/$BASH_IT_CONFIG_FILE"

  local md5_conf=$(md5sum "$BASH_IT_TEST_HOME/$BASH_IT_CONFIG_FILE" | awk '{print $1}')

  assert_equal "$md5_bak" "$md5_conf"
}

@test "uninstall: run the uninstall script without an existing backup file" {
  cd "$BASH_IT"

  echo "test file content for original file" > "$BASH_IT_TEST_HOME/$BASH_IT_CONFIG_FILE"
  local md5_orig=$(md5sum "$BASH_IT_TEST_HOME/$BASH_IT_CONFIG_FILE" | awk '{print $1}')

  ./uninstall.sh

  assert_success

  assert_file_exist "$BASH_IT_TEST_HOME/$BASH_IT_CONFIG_FILE.uninstall"
  assert_file_not_exist "$BASH_IT_TEST_HOME/$BASH_IT_CONFIG_FILE.bak"
  assert_file_not_exist "$BASH_IT_TEST_HOME/$BASH_IT_CONFIG_FILE"

  local md5_uninstall=$(md5sum "$BASH_IT_TEST_HOME/$BASH_IT_CONFIG_FILE.uninstall" | awk '{print $1}')

  assert_equal "$md5_orig" "$md5_uninstall"
}
