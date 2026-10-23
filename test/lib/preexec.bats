# shellcheck shell=bats
# shellcheck disable=SC2030 disable=SC2031

load ../test_helper

function local_setup {
	setup_test_fixture
	export __bp_enable_subshells=yas
}

# PROMPT_COMMAND is an array in Bash >= 5.1 and a scalar before; join with newlines to compare either
function prompt_command_lines() {
	local IFS=$'\n' lines
	lines="${PROMPT_COMMAND[*]}"
	printf '%s' "${lines#$'\n'}"
}

@test "vendor preexec: __bp_install_after_session_init() without existing" {
	test_prompt_string=""
	export PROMPT_COMMAND="$test_prompt_string"

	run load ../../vendor/github.com/rcaloras/bash-preexec/bash-preexec.sh
	assert_success
	load ../../vendor/github.com/rcaloras/bash-preexec/bash-preexec.sh

	# shellcheck disable=SC2016
	assert_equal "$(prompt_command_lines)" '__bp_install "$_"'
}

@test "vendor preexec: __bp_install_after_session_init() with existing" {
	test_prompt_string="nah"
	export PROMPT_COMMAND="$test_prompt_string"

	run load ../../vendor/github.com/rcaloras/bash-preexec/bash-preexec.sh
	assert_success
	load ../../vendor/github.com/rcaloras/bash-preexec/bash-preexec.sh

	# shellcheck disable=SC2016
	assert_equal "$(prompt_command_lines)" "$test_prompt_string"$'\n__bp_install "$_"'
}

@test "vendor preexec: __bp_install_after_session_init() delayed" {
	test_prompt_string="nah"
	export PROMPT_COMMAND="$test_prompt_string"
	export __bp_delay_install="blarg"

	run load ../../vendor/github.com/rcaloras/bash-preexec/bash-preexec.sh
	assert_success
	load ../../vendor/github.com/rcaloras/bash-preexec/bash-preexec.sh

	assert_equal "${PROMPT_COMMAND}" "$test_prompt_string"

	run __bp_install_after_session_init
	assert_success

	__bp_install_after_session_init
	# shellcheck disable=SC2016
	assert_equal "$(prompt_command_lines)" "$test_prompt_string"$'\n__bp_install "$_"'
}

@test "vendor preexec: __bp_install() without existing" {
	test_prompt_string=""
	export PROMPT_COMMAND="$test_prompt_string"

	run load ../../vendor/github.com/rcaloras/bash-preexec/bash-preexec.sh
	assert_success
	load ../../vendor/github.com/rcaloras/bash-preexec/bash-preexec.sh

	run __bp_install
	assert_success

	__bp_install
	# shellcheck disable=SC2016
	assert_equal "$(prompt_command_lines)" $'__bp_precmd_invoke_cmd "$_"\n__bp_interactive_mode'
}

@test "vendor preexec: __bp_install() with existing" {
	test_prompt_string="nah"
	export PROMPT_COMMAND="$test_prompt_string"

	run load ../../vendor/github.com/rcaloras/bash-preexec/bash-preexec.sh
	assert_success
	load ../../vendor/github.com/rcaloras/bash-preexec/bash-preexec.sh

	run __bp_install
	assert_success

	__bp_install
	# shellcheck disable=SC2016
	assert_equal "$(prompt_command_lines)" $'__bp_precmd_invoke_cmd "$_"\n'"$test_prompt_string"$'\n__bp_interactive_mode'
}

@test "vendor preexec: precmd_functions and preexec_functions are global when sourced from a function" {
	# shellcheck disable=SC2317
	function source_and_append() {
		# shellcheck disable=SC1091
		source "${BATS_TEST_DIRNAME}/../../vendor/github.com/rcaloras/bash-preexec/bash-preexec.sh"
		precmd_functions+=(test_precmd)
		preexec_functions+=(test_preexec)
	}

	source_and_append

	assert_equal "${precmd_functions[*]}" "test_precmd"
	assert_equal "${preexec_functions[*]}" "test_preexec"
}

@test "lib preexec: __bp_require_not_readonly()" {
	run type -t __bp_require_not_readonly
	assert_failure

	run load ../../lib/preexec.bash
	assert_success
	load ../../lib/preexec.bash

	run type -t __bp_require_not_readonly
	assert_success

	export HISTCONTROL=blah:blah PROMPT_COMMAND="silly;rabbit"
	readonly HISTCONTROL PROMPT_COMMAND

	run __bp_require_not_readonly
	assert_success
}

@test "lib preexec: __bp_adjust_histcontrol()" {
	run type -t __bp_adjust_histcontrol
	assert_failure

	run load ../../lib/preexec.bash
	assert_success
	load ../../lib/preexec.bash

	run type -t __bp_adjust_histcontrol
	assert_success

	test_history_control_string="ignoreall:ignoredups:ignorespace:erasedups"
	export HISTCONTROL="${test_history_control_string}"

	run __bp_adjust_histcontrol
	assert_success
	assert_equal "${HISTCONTROL}" "${test_history_control_string}"
}

@test "lib preexec: __check_precmd_conflict()" {
	test_precmd_function_name="test"
	setup_libs "preexec"

	run __check_precmd_conflict "$test_precmd_function_name"
	assert_failure

	export precmd_functions=("$test_precmd_function_name")

	run __check_precmd_conflict "$test_precmd_function_name"
	assert_success
}

@test "lib preexec: __check_preexec_conflict()" {
	test_preexec_function_name="test"
	setup_libs "preexec"

	run __check_preexec_conflict "$test_preexec_function_name"
	assert_failure

	export preexec_functions=("$test_preexec_function_name")

	run __check_preexec_conflict "$test_preexec_function_name"
	assert_success
}

@test "lib preexec: safe_append_prompt_command()" {
	test_precmd_function_name="test"
	setup_libs "preexec"

	export precmd_functions=()
	assert_equal "${precmd_functions[*]}" ""

	run safe_append_prompt_command "$test_precmd_function_name"
	assert_success

	safe_append_prompt_command "$test_precmd_function_name"
	assert_equal "${precmd_functions[*]}" "$test_precmd_function_name"
}

@test "lib preexec: safe_append_preexec()" {
	test_preexec_function_name="test"
	setup_libs "preexec"

	export preexec_functions=()
	assert_equal "${preexec_functions[*]}" ""

	run safe_append_preexec "$test_preexec_function_name"
	assert_success

	safe_append_preexec "$test_preexec_function_name"
	assert_equal "${preexec_functions[*]}" "$test_preexec_function_name"
}
