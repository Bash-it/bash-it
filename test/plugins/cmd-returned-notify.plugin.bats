#!/usr/bin/env bats

load ../test_helper
load ../../lib/helpers
load "${BASH_IT}/vendor/github.com/erichs/composure/composure.sh"

load ../../plugins/available/cmd-returned-notify.plugin

@test "plugins cmd-returned-notify: notify after elapsed time" {
    export NOTIFY_IF_COMMAND_RETURNS_AFTER=0
    export LAST_COMMAND_TIME=$(date +%s)
    sleep 1
    run precmd_return_notification
    assert_success
    assert_output $'\a'
}

@test "plugins cmd-returned-notify: do not notify before elapsed time" {
    export NOTIFY_IF_COMMAND_RETURNS_AFTER=10
    export LAST_COMMAND_TIME=$(date +%s)
    sleep 1
    run precmd_return_notification
    assert_success
    assert_output $''
}

@test "plugins cmd-returned-notify: preexec no output" {
    export LAST_COMMAND_TIME=
    run preexec_return_notification
    assert_success
    assert_output ""
}

@test "plugins cmd-returned-notify: preexec no output env set" {
    export LAST_COMMAND_TIME=$(date +%s)
    run preexec_return_notification
    assert_failure
    assert_output ""
}

@test "plugins cmd-returned-notify: preexec set LAST_COMMAND_TIME" {
    export LAST_COMMAND_TIME=
    assert_equal "${LAST_COMMAND_TIME}" ""
    NOW=$(date +%s)
    preexec_return_notification
    assert_equal "${LAST_COMMAND_TIME}" "${NOW}"
}
