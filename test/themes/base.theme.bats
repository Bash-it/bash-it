#!/usr/bin/env bats

load ../test_helper
load ../../lib/composure

cite _about _param _example _group _author _version

load ../../lib/helpers
load ../../themes/base.theme

@test 'themes base: battery_percentage should not exist' {
  run type -a battery_percentage &> /dev/null
  assert_failure
}

@test 'themes base: battery_percentage should exist if battery plugin loaded' {
  load ../../plugins/available/battery.plugin

  run type -a battery_percentage &> /dev/null
  assert_success
}

@test 'themes base: battery_char should exist' {
  run type -a battery_char &> /dev/null
  assert_success

  run battery_char
  assert_success
  assert_line -n 0 ""

  run type -a battery_char
  assert_line "    echo -n"
}

@test 'themes base: battery_char should exist if battery plugin loaded' {
  unset -f battery_char
  load ../../plugins/available/battery.plugin
  load ../../themes/base.theme

  run type -a battery_char &> /dev/null
  assert_success

  run battery_char
  assert_success

  run type -a battery_char
  assert_line '    if [[ "${THEME_BATTERY_PERCENTAGE_CHECK}" = true ]]; then'
}

@test 'themes base: battery_charge should exist' {
  run type -a battery_charge &> /dev/null
  assert_success

  run battery_charge
  assert_success
  assert_line -n 0 ""
}

@test 'themes base: battery_charge should exist if battery plugin loaded' {
  unset -f battery_charge
  load ../../plugins/available/battery.plugin
  load ../../themes/base.theme

  run type -a battery_charge &> /dev/null
  assert_success

  run battery_charge
  assert_success

  run type -a battery_charge
  assert_line '        no)'
}
