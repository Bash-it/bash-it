# shellcheck shell=bats

load "${MAIN_BASH_IT_DIR?}/test/test_helper.bash"

function local_setup_file() {
  setup_libs "helpers"
}

@test "_bash-it-component-item-is-enabled() - for a disabled item" {
  run _bash-it-component-item-is-enabled aliases svn
  assert_failure
}

@test "_bash-it-component-item-is-enabled() - for an enabled/disabled item" {
  run bash-it enable alias svn
  assert_line -n 0 'svn enabled with priority 150.'

  run _bash-it-component-item-is-enabled alias svn
  assert_success
  run _bash-it-component-item-is-disabled alias svn
  assert_failure

  run bash-it disable alias svn
  assert_line -n 0 'svn disabled.'

  run _bash-it-component-item-is-enabled alias svn
  assert_failure
  run _bash-it-component-item-is-disabled alias svn
  assert_success
}

@test "_bash-it-component-item-is-disabled() - for a disabled item" {
  run _bash-it-component-item-is-disabled alias svn
  assert_success
}

@test "_bash-it-component-item-is-disabled() - for an enabled/disabled item" {
  run bash-it enable alias svn
  assert_line -n 0 'svn enabled with priority 150.'

  run _bash-it-component-item-is-disabled alias svn
  assert_failure
  run _bash-it-component-item-is-enabled alias svn
  assert_success

  run bash-it disable alias svn
  assert_line -n 0 'svn disabled.'

  run _bash-it-component-item-is-disabled alias svn
  assert_success
  run _bash-it-component-item-is-enabled alias svn
  assert_failure
}

@test "_bash-it-array-contains-element() - when match is found, and is the first" {
  declare -a fruits=(apple pear orange mandarin)
  run _bash-it-array-contains-element apple "${fruits[@]}"
  assert_success
}

@test "_bash-it-array-contains-element() - when match is found, and is the last" {
  declare -a fruits=(apple pear orange mandarin)
  run _bash-it-array-contains-element mandarin "${fruits[@]}"
  assert_success
}

@test "_bash-it-array-contains-element() - when match is found, and is in the middle" {
  declare -a fruits=(apple pear orange mandarin)
  run _bash-it-array-contains-element pear "${fruits[@]}"
  assert_success
}

@test "_bash-it-array-contains-element() - when match is found, and it has spaces" {
  declare -a fruits=(apple pear orange mandarin "yellow watermelon")
  run _bash-it-array-contains-element "yellow watermelon" "${fruits[@]}"
  assert_success
}

@test "_bash-it-array-contains-element() - when match is not found" {
  declare -a fruits=(apple pear orange mandarin)
  run _bash-it-array-contains-element xyz "${fruits[@]}"
  assert_failure
}
