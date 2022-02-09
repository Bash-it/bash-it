#!/usr/bin/env bats

load ../test_helper
load ../test_helper_libs
load ../../themes/base.theme

@test 'themes base: battery_percentage should exist if battery plugin loaded' {
  run type -t battery_percentage
  assert_failure

  load "../../lib/battery.bash"

  run type -t battery_percentage
  assert_success
  assert_output "function"
}

@test 'themes base: battery_char should exist if battery plugin loaded' {
  run type -t battery_char
  assert_success
  assert_output "function"

  load "../../lib/battery.bash"
  run type -t battery_percentage
  assert_success
  assert_output "function"

  run battery_char
  assert_success

  run type -a battery_char
  assert_output --partial 'THEME_BATTERY_PERCENTAGE_CHECK'
}

@test 'themes base: battery_charge should exist if battery plugin loaded' {
  run type -t battery_charge
  assert_failure

  load "../../lib/battery.bash"

  run type -t battery_charge
  assert_success
  assert_output "function"

  run battery_charge
  assert_success
}
