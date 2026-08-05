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
	complete -r herdr 2> /dev/null || true
}

function _mock_herdr() {
	printf '%s\n' \
		'#!/usr/bin/env bash' \
		'[[ "$*" == "completion bash" ]] && echo "complete -o nospace herdr"' \
		> "${MOCK_BIN}/herdr"
	chmod +x "${MOCK_BIN}/herdr"
	PATH="${MOCK_BIN}:${PATH}"
}

@test "completion herdr: fails to load when herdr is not in PATH" {
	PATH="${MOCK_BIN}" run source "${BASH_IT?}/completion/available/herdr.completion.bash"
	assert_failure
}

@test "completion herdr: loads successfully when herdr is available" {
	_mock_herdr
	run source "${BASH_IT?}/completion/available/herdr.completion.bash"
	assert_success
}

@test "completion herdr: skips eval when completion is already managed externally" {
	_mock_herdr
	complete -F : herdr
	source "${BASH_IT?}/completion/available/herdr.completion.bash"
	run complete -p herdr
	assert_output "complete -F : herdr"
}
