unset BASH_IT_THEME
unset GIT_HOSTING
unset NGINX_PATH
unset IRC_CLIENT
unset TODO
unset SCM_CHECK
unset BASH_IT_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE

export TEST_MAIN_DIR="${BATS_TEST_DIRNAME}/.."
export TEST_DEPS_DIR="${TEST_DEPS_DIR-${TEST_MAIN_DIR}/../test_lib}"

# be independent of git's system configuration
export GIT_CONFIG_NOSYSTEM

load "${TEST_DEPS_DIR}/bats-support/load.bash"
load "${TEST_DEPS_DIR}/bats-assert/load.bash"
load "${TEST_DEPS_DIR}/bats-file/load.bash"

local_setup() {
  true
}

local_teardown() {
  true
}

# This function sets up a local test fixture, i.e. a completely
# fresh and isolated Bash-it directory. This is done to avoid
# messing with your own Bash-it source directory.
# If you need this, call it in your .bats file's `local_setup` function.
setup_test_fixture() {
  mkdir -p "$BASH_IT"
  lib_directory="$(cd "$(dirname "$0")" && pwd)"
  local src_topdir="$lib_directory/../../../.."

  if command -v rsync &> /dev/null
  then
    # Use rsync to copy Bash-it to the temp folder
    rsync -qavrKL -d --delete-excluded --exclude=.git --exclude=enabled "$src_topdir" "$BASH_IT"
  else
    rm -rf "$BASH_IT"
    mkdir -p "$BASH_IT"

    find "$src_topdir" \
      -mindepth 1 -maxdepth 1 \
      -not -name .git \
      -exec cp -r {} "$BASH_IT" \;
  fi

  rm -rf "$BASH_IT"/enabled
  rm -rf "$BASH_IT"/aliases/enabled
  rm -rf "$BASH_IT"/completion/enabled
  rm -rf "$BASH_IT"/plugins/enabled

  mkdir -p "$BASH_IT"/enabled
  mkdir -p "$BASH_IT"/aliases/enabled
  mkdir -p "$BASH_IT"/completion/enabled
  mkdir -p "$BASH_IT"/plugins/enabled

  # Some tests use the BASH_IT_TEST_HOME variable, e.g. install/uninstall
  export BASH_IT_TEST_HOME="$TEST_TEMP_DIR"
}

setup() {
  # The `temp_make` function from "bats-file" requires the tralston/bats-file fork,
  # since the original ztombol/bats-file's `temp_make` does not work on macOS.
  TEST_TEMP_DIR="$(temp_make --prefix 'bash-it-test-')"
  export TEST_TEMP_DIR

  export BASH_IT_TEST_DIR="${TEST_TEMP_DIR}/.bash_it"

  export BASH_IT_ROOT="${BASH_IT_TEST_DIR}/root"
  export BASH_IT=$BASH_IT_TEST_DIR

  mkdir -p -- "${BASH_IT_ROOT}"

  # Some tools, e.g. `git` use configuration files from the $HOME directory,
  # which interferes with our tests. The only way to keep `git` from doing this
  # seems to set HOME explicitly to a separate location.
  # Refer to https://git-scm.com/docs/git-config#FILES.
  unset XDG_CONFIG_HOME
  export HOME="${TEST_TEMP_DIR}"
  mkdir -p "${HOME}"

  # For `git` tests to run well, user name and email need to be set.
  # Refer to https://git-scm.com/docs/git-commit#_commit_information.
  # This goes to the test-specific config, due to the $HOME overridden above.
  git config --global user.name "John Doe"
  git config --global user.email "johndoe@example.com"

  local_setup
}

teardown() {
  local_teardown

  rm -rf "${BASH_IT_TEST_DIR}"
  temp_del "${TEST_TEMP_DIR}"
}
