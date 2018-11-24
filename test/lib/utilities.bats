#!/usr/bin/env bats

load ../test_helper
load ../../lib/composure
load ../../lib/helpers
load ../../lib/utilities
load ../../lib/search

cite _about _param _example _group _author _version

function local_setup {
  mkdir -p "$BASH_IT"
  lib_directory="$(cd "$(dirname "$0")" && pwd)"
  # Use rsync to copy Bash-it to the temp folder
  # rsync is faster than cp, since we can exclude the large ".git" folder
  rsync -qavrKL -d --delete-excluded --exclude=.git $lib_directory/../../.. "$BASH_IT"

  rm -rf "$BASH_IT"/enabled
  rm -rf "$BASH_IT"/aliases/enabled
  rm -rf "$BASH_IT"/completion/enabled
  rm -rf "$BASH_IT"/plugins/enabled
  rm -rf "$BASH_IT"/tmp/cache

  mkdir -p "$BASH_IT"/enabled
  mkdir -p "$BASH_IT"/aliases/enabled
  mkdir -p "$BASH_IT"/completion/enabled
  mkdir -p "$BASH_IT"/plugins/enabled
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
