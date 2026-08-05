# shellcheck shell=bats

load "${MAIN_BASH_IT_DIR?}/test/test_helper.bash"

function local_setup_file() {
	setup_libs "helpers"
	load "${BASH_IT?}/lib/completion.bash"
}

function local_setup() {
	MOCK_BIN="${BATS_TEST_TMPDIR}/mock-bin"
	mkdir -p "${MOCK_BIN}"
	_SAVED_PATH="${PATH}"
}

function local_teardown() {
	PATH="${_SAVED_PATH}"
	complete -r op 2> /dev/null || true
}

function _mock_op() {
	printf '%s\n' \
		'#!/usr/bin/env bash' \
		'[[ "$*" == "completion bash" ]] && echo "complete -o nospace op"' \
		> "${MOCK_BIN}/op"
	chmod +x "${MOCK_BIN}/op"
	PATH="${MOCK_BIN}:${PATH}"
}

@test "completion op: fails to load when op is not in PATH" {
	PATH="${MOCK_BIN}" run source "${BASH_IT?}/completion/available/op.completion.bash"
	assert_failure
}

@test "completion op: loads successfully when op is available" {
	_mock_op
	run source "${BASH_IT?}/completion/available/op.completion.bash"
	assert_success
}

@test "completion op: skips eval when completion is already managed externally" {
	_mock_op
	complete -F : op
	source "${BASH_IT?}/completion/available/op.completion.bash"
	run complete -p op
	assert_output "complete -F : op"
}
