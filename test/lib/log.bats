# shellcheck shell=bats
# shellcheck disable=SC2034

load "${MAIN_BASH_IT_DIR?}/test/test_helper.bash"

function local_setup_file() {
	setup_libs "log"
}

@test "lib log: basic debug logging with BASH_IT_LOG_LEVEL_ALL" {
	BASH_IT_LOG_LEVEL=${BASH_IT_LOG_LEVEL_ALL?}
	run _log_debug "test test test"
	assert_output "DEBUG: default: test test test"
}

@test "lib log: basic warning logging with BASH_IT_LOG_LEVEL_ALL" {
	BASH_IT_LOG_LEVEL=${BASH_IT_LOG_LEVEL_ALL?}
	run _log_warning "test test test"
	assert_output " WARN: default: test test test"
}

@test "lib log: basic error logging with BASH_IT_LOG_LEVEL_ALL" {
	BASH_IT_LOG_LEVEL=${BASH_IT_LOG_LEVEL_ALL?}
	run _log_error "test test test"
	assert_output "ERROR: default: test test test"
}

@test "lib log: basic debug logging with BASH_IT_LOG_LEVEL_WARNING" {
	BASH_IT_LOG_LEVEL=${BASH_IT_LOG_LEVEL_WARNING?}
	run _log_debug "test test test"
	assert_output ""
}

@test "lib log: basic warning logging with BASH_IT_LOG_LEVEL_WARNING" {
	BASH_IT_LOG_LEVEL=${BASH_IT_LOG_LEVEL_WARNING?}
	run _log_warning "test test test"
	assert_output " WARN: default: test test test"
}

@test "lib log: basic error logging with BASH_IT_LOG_LEVEL_WARNING" {
	BASH_IT_LOG_LEVEL=${BASH_IT_LOG_LEVEL_WARNING?}
	run _log_error "test test test"
	assert_output "ERROR: default: test test test"
}

@test "lib log: basic debug logging with BASH_IT_LOG_LEVEL_ERROR" {
	BASH_IT_LOG_LEVEL=${BASH_IT_LOG_LEVEL_ERROR?}
	run _log_debug "test test test"
	assert_output ""
}

@test "lib log: basic warning logging with BASH_IT_LOG_LEVEL_ERROR" {
	BASH_IT_LOG_LEVEL=${BASH_IT_LOG_LEVEL_ERROR?}
	run _log_warning "test test test"
	assert_output ""
}

@test "lib log: basic error logging with BASH_IT_LOG_LEVEL_ERROR" {
	BASH_IT_LOG_LEVEL=${BASH_IT_LOG_LEVEL_ERROR?}
	run _log_error "test test test"
	assert_output "ERROR: default: test test test"
}

@test "lib log: basic debug silent logging" {
	run _log_debug "test test test"
	assert_output ""
}

@test "lib log: basic warning silent logging" {
	run _log_warning "test test test"
	assert_output ""
}

@test "lib log: basic error silent logging" {
	run _log_error "test test test"
	assert_output ""
}

@test "lib log: logging with prefix" {
	BASH_IT_LOG_LEVEL=${BASH_IT_LOG_LEVEL_ALL?}
	BASH_IT_LOG_PREFIX="nice: prefix: "
	run _log_debug "test test test"
	assert_output "DEBUG: nice: prefix: test test test"
}
