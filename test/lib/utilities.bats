#!/usr/bin/env bats

load ../test_helper
load ../../lib/composure
load ../../lib/helpers
load ../../lib/utilities
load ../../lib/search

cite _about _param _example _group _author _version

function local_setup {
  setup_test_fixture
}

function has_match() {
  $(_bash-it-array-contains-element ${@}) && echo "has" "$1"
}

function item_enabled() {
  $(_bash-it-component-item-is-enabled ${@}) && echo "$1" "$2" "is enabled"
}

function item_disabled() {
  $(_bash-it-component-item-is-disabled ${@}) && echo "$1" "$2" "is disabled"
}

@test "_bash-it-component-item-is-enabled() - for a disabled item" {
  run item_enabled aliases svn
  assert_line -n 0 ''
}

@test "_bash-it-component-item-is-enabled() - for an enabled/disabled item" {
  run bash-it enable alias svn
  assert_line -n 0 'svn enabled with priority 150.'

  run item_enabled alias svn
  assert_line -n 0 'alias svn is enabled'

  run bash-it disable alias svn
  assert_line -n 0 'svn disabled.'

  run item_enabled alias svn
  assert_line -n 0 ''
}

@test "_bash-it-component-item-is-disabled() - for a disabled item" {
  run item_disabled alias svn
  assert_line -n 0 'alias svn is disabled'
}

@test "_bash-it-component-item-is-disabled() - for an enabled/disabled item" {
  run bash-it enable alias svn
  assert_line -n 0 'svn enabled with priority 150.'

  run item_disabled alias svn
  assert_line -n 0 ''

  run bash-it disable alias svn
  assert_line -n 0 'svn disabled.'

  run item_disabled alias svn
  assert_line -n 0 'alias svn is disabled'
}

@test "_bash-it-array-contains-element() - when match is found, and is the first" {
  declare -a fruits=(apple pear orange mandarin)
  run has_match apple "${fruits[@]}"
  assert_line -n 0 'has apple'
}

@test "_bash-it-array-contains-element() - when match is found, and is the last" {
  declare -a fruits=(apple pear orange mandarin)
  run has_match mandarin "${fruits[@]}"
  assert_line -n 0 'has mandarin'
}

@test "_bash-it-array-contains-element() - when match is found, and is in the middle" {
  declare -a fruits=(apple pear orange mandarin)
  run has_match pear "${fruits[@]}"
  assert_line -n 0 'has pear'
}

@test "_bash-it-array-contains-element() - when match is found, and it has spaces" {
  declare -a fruits=(apple pear orange mandarin "yellow watermelon")
  run has_match "yellow watermelon" "${fruits[@]}"
  assert_line -n 0 'has yellow watermelon'
}

@test "_bash-it-array-contains-element() - when match is not found" {
  declare -a fruits=(apple pear orange mandarin)
  run has_match xyz "${fruits[@]}"
  assert_line -n 0 ''
}

@test "_bash-it-human-duration() - under a minute only displays second count" {
  run _bash-it-human-duration 2
  [ "$output" = "2s" ]

  run _bash-it-human-duration 30
  [ "$output" = "30s" ]

  run _bash-it-human-duration 59
  [ "$output" = "59s" ]
}

@test "_bash-it-human-duration() - over a minute, but under an hour displays mm:ss" {
  run _bash-it-human-duration 60
  [ "$output" = "01m:00s" ]

  run _bash-it-human-duration 83
  [ "$output" = "01m:23s" ]

  run _bash-it-human-duration 3599
  [ "$output" = "59m:59s" ]
}

@test "_bash-it-human-duration() - over an hour, displays in the hh:mm:ss format" {
  run _bash-it-human-duration 3600
  [ "$output" = "01h:00m:00s" ]

  run _bash-it-human-duration 3700
  [ "$output" = "01h:01m:40s" ]

  run _bash-it-human-duration $(( 3600 * 24 - 1 ))
  [ "$output" = "23h:59m:59s" ]
}

@test "_bash-it-human-duration() - duration over 1 day - starts displaying number of days as well" {
  run _bash-it-human-duration 86400
  [ "$output" = "1 day(s), 00h:00m:00s" ]

  run _bash-it-human-duration $(( 3600 * 24 * 3 + 3600 * 5 + 60 * 7 + 23 ))
  [ "$output" = "3 day(s), 05h:07m:23s" ]
}
