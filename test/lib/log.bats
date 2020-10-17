#!/usr/bin/env bats

load ../test_helper
load ../../lib/composure
load ../../lib/appearance
load ../../plugins/available/base.plugin

cite _about _param _example _group _author _version
load ../../lib/log

@test "lib log: basic debug logging with BASH_IT_LOG_LEVEL_ALL" {
  BASH_IT_LOG_LEVEL=$BASH_IT_LOG_LEVEL_ALL
  run _log_debug "test test test"
  assert_output "DEBUG: test test test"
}

@test "lib log: basic warning logging with BASH_IT_LOG_LEVEL_ALL" {
  BASH_IT_LOG_LEVEL=$BASH_IT_LOG_LEVEL_ALL
  run _log_warning "test test test"
  assert_output " WARN: test test test"
}

@test "lib log: basic error logging with BASH_IT_LOG_LEVEL_ALL" {
  BASH_IT_LOG_LEVEL=$BASH_IT_LOG_LEVEL_ALL
  run _log_error "test test test"
  assert_output "ERROR: test test test"
}

@test "lib log: basic debug logging with BASH_IT_LOG_LEVEL_WARNING" {
  BASH_IT_LOG_LEVEL=$BASH_IT_LOG_LEVEL_WARNING
  run _log_debug "test test test"
  refute_output
}

@test "lib log: basic warning logging with BASH_IT_LOG_LEVEL_WARNING" {
  BASH_IT_LOG_LEVEL=$BASH_IT_LOG_LEVEL_WARNING
  run _log_warning "test test test"
  assert_output " WARN: test test test"
}

@test "lib log: basic error logging with BASH_IT_LOG_LEVEL_WARNING" {
  BASH_IT_LOG_LEVEL=$BASH_IT_LOG_LEVEL_WARNING
  run _log_error "test test test"
  assert_output "ERROR: test test test"
}


@test "lib log: basic debug logging with BASH_IT_LOG_LEVEL_ERROR" {
  BASH_IT_LOG_LEVEL=$BASH_IT_LOG_LEVEL_ERROR
  run _log_debug "test test test"
  refute_output
}

@test "lib log: basic warning logging with BASH_IT_LOG_LEVEL_ERROR" {
  BASH_IT_LOG_LEVEL=$BASH_IT_LOG_LEVEL_ERROR
  run _log_warning "test test test"
  refute_output
}

@test "lib log: basic error logging with BASH_IT_LOG_LEVEL_ERROR" {
  BASH_IT_LOG_LEVEL=$BASH_IT_LOG_LEVEL_ERROR
  run _log_error "test test test"
  assert_output "ERROR: test test test"
}

@test "lib log: basic debug silent logging" {
  run _log_debug "test test test"
  refute_output
}

@test "lib log: basic warning silent logging" {
  run _log_warning "test test test"
  refute_output
}

@test "lib log: basic error silent logging" {
  run _log_error "test test test"
  refute_output
}

@test "lib log: logging with prefix" {
  BASH_IT_LOG_LEVEL=$BASH_IT_LOG_LEVEL_ALL
  BASH_IT_LOG_PREFIX="nice: prefix: "
  run _log_debug "test test test"
  assert_output "DEBUG: nice: prefix: test test test"
}
