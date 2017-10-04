unset BASH_IT_THEME
unset GIT_HOSTING
unset NGINX_PATH
unset IRC_CLIENT
unset TODO
unset SCM_CHECK

BASH_IT_TEST_DIR="${BATS_TMPDIR}/.bash_it"

# guard against executing this block twice due to bats internals
if [ "$BASH_IT_ROOT" != "${BASH_IT_TEST_DIR}/root" ]; then
  export BASH_IT_ROOT="${BASH_IT_TEST_DIR}/root"
  export BASH_IT=$BASH_IT_TEST_DIR
fi

export TEST_MAIN_DIR="${BATS_TEST_DIRNAME}/.."
export TEST_DEPS_DIR="${TEST_DEPS_DIR-${TEST_MAIN_DIR}/../test_lib}"

load "${TEST_DEPS_DIR}/bats-support/load.bash"
load "${TEST_DEPS_DIR}/bats-assert/load.bash"

local_setup() {
  true
}

local_teardown() {
  true
}

setup() {
  mkdir -p -- "${BASH_IT_ROOT}"

  local_setup
}

teardown() {
  local_teardown

  rm -rf "${BASH_IT_TEST_DIR}"
}
