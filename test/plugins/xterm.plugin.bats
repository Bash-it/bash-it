# shellcheck shell=bats
# shellcheck disable=SC2034

load "${MAIN_BASH_IT_DIR?}/test/test_helper.bash"

function local_setup_file() {
	setup_libs "helpers"
	load "${BASH_IT?}/plugins/available/xterm.plugin.bash"
}

@test "plugins xterm: shorten command output" {
	SHORT_TERM_LINE=true
	run _short-command "${BASH_IT}/test/fixtures/plugin/xterm/files"/*
	assert_success
	assert_output "${BASH_IT}/test/fixtures/plugin/xterm/files/arg0"
}

@test "plugins xterm: full command output" {
	SHORT_TERM_LINE=false
	run _short-command "${BASH_IT}/test/fixtures/plugin/xterm/files"/*
	assert_success
	assert_output "$(echo "${BASH_IT}/test/fixtures/plugin/xterm/files"/*)"
}

@test "plugins xterm: shorten dirname output" {
	SHORT_TERM_LINE=true
	run _short-dirname
	assert_success
	assert_output "$(basename "${PWD}")"
}

@test "plugins xterm: full dirname output" {
	SHORT_TERM_LINE=false
	run _short-dirname
	assert_success
	assert_output "${PWD}"
}

@test "plugins xterm: set xterm title" {
	run set_xterm_title title
	assert_success
	assert_output $'\033]0;title\007'
}
