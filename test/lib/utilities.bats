# shellcheck shell=bats

load "${MAIN_BASH_IT_DIR?}/test/test_helper.bash"

function local_setup_file() {
	setup_libs "helpers"
}

@test "utilities: _is_function: _command_exists" {
	run _is_function _command_exists
	assert_success
}

@test "utilities: _command_exists function positive test ls" {
	run _command_exists ls
	assert_success
}

@test "utilities: _command_exists function positive test bash-it" {
	run _command_exists bash-it
	assert_success
}

@test "utilities: _command_exists function negative test" {
	run _command_exists "__addfkds_dfdsjdf_${RANDOM:-}"
	assert_failure
}

@test "utilities: _is_function: _binary_exists" {
	run _is_function _binary_exists
	assert_success
}

@test "utilities: _binary_exists function positive test ls" {
	run _binary_exists ls
	assert_success
}

@test "utilities: _binary_exists function negative test function" {
	run _binary_exists _binary_exists
	assert_failure
}

@test "utilities: _binary_exists function negative test" {
	run _binary_exists "__addfkds_dfdsjdf_${RANDOM:-}"
	assert_failure
}

@test "utilities: _is_function: _completion_exists" {
	run _is_function _completion_exists
	assert_success
}

@test "utilities: _is_function new function" {
	local teh_new_func="__addfkds_dfdsjdf_${RANDOM:-}"
	run _is_function "${teh_new_func?}"
	assert_failure

	cite "${teh_new_func?}"
	run _is_function "${teh_new_func?}"
	assert_success
}

@test "utilities: _command_exists new function" {
	local teh_new_func="__addfkds_dfdsjdf_${RANDOM:-}"
	run _command_exists "${teh_new_func?}"
	assert_failure

	cite "${teh_new_func?}"
	run _command_exists "${teh_new_func?}"
	assert_success
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
