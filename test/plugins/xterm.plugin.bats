#!/usr/bin/env bats

load ../test_helper
load ../../lib/helpers
load "${BASH_IT}/vendor/github.com/erichs/composure/composure.sh"

load ../../plugins/available/xterm.plugin

function local_setup {
  setup_test_fixture

  # Copy the test fixture to the Bash-it folder
  if _command_exists rsync; then
    rsync -a "$BASH_IT/test/fixtures/plugin/xterm/" "$BASH_IT/"
  else
    find "$BASH_IT/test/fixtures/plugin/xterm" \
      -mindepth 1 -maxdepth 1 \
      -exec cp -r {} "$BASH_IT/" \;
  fi
}

@test "plugins xterm: shorten command output" {
    export SHORT_TERM_LINE=true
    run _short-command ${BASH_IT}/test/fixtures/plugin/xterm/files/*
    assert_success
    assert_output ${BASH_IT}/test/fixtures/plugin/xterm/files/arg0
}

@test "plugins xterm: full command output" {
    export SHORT_TERM_LINE=false
    run _short-command ${BASH_IT}/test/fixtures/plugin/xterm/files/*
    assert_success
    assert_output "$(echo ${BASH_IT}/test/fixtures/plugin/xterm/files/*)"
}

@test "plugins xterm: shorten dirname output" {
    export SHORT_TERM_LINE=true
    run _short-dirname
    assert_success
    assert_output "$(basename $PWD)"
}

@test "plugins xterm: full dirname output" {
    export SHORT_TERM_LINE=false
    run _short-dirname
    assert_success
    assert_output $PWD
}

@test "plugins xterm: set xterm title" {
    run set_xterm_title title
    assert_success
    assert_output $'\033]0;title\007'
}
