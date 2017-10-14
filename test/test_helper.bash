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
load "${TEST_DEPS_DIR}/bats-file/load.bash"

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

# Fail and display path of the link if it does not exist. Also fails
# if the path exists, but is not a link.
# This function is the logical complement of `assert_file_not_exist'.
# There is no dedicated function for checking that a link does not exist.
#
# Globals:
#   BATSLIB_FILE_PATH_REM
#   BATSLIB_FILE_PATH_ADD
# Arguments:
#   $1 - path
# Returns:
#   0 - link exists and is a link
#   1 - otherwise
# Outputs:
#   STDERR - details, on failure
assert_link_exist() {
  local -r file="$1"
  local -r target="$2"
  if [[ ! -L "$file" ]]; then
    local -r rem="$BATSLIB_FILE_PATH_REM"
    local -r add="$BATSLIB_FILE_PATH_ADD"
    if [[ -e "$file" ]]; then
      batslib_print_kv_single 4 'path' "${file/$rem/$add}" \
        | batslib_decorate 'exists, but is not a link' \
        | fail
    else
      batslib_print_kv_single 4 'path' "${file/$rem/$add}" \
        | batslib_decorate 'link does not exist' \
        | fail
    fi
  else
    if [ -n "$target" ]; then
      local link_target=''
      link_target=$(readlink "$file")
      if [[ "$link_target" != "$target" ]]; then
        batslib_print_kv_single_or_multi 8 'path' "${file/$rem/$add}" \
            'expected' "$target" \
            'actual'   "$link_target" \
          | batslib_decorate 'link exists, but does not point to target file' \
          | fail
      fi
    fi
  fi
}
