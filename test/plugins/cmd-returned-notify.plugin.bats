# shellcheck shell=bats
# shellcheck disable=SC2034

load "${MAIN_BASH_IT_DIR?}/test/test_helper.bash"

function local_setup_file() {
	setup_libs "command_duration"
	load "${BASH_IT?}/plugins/available/cmd-returned-notify.plugin.bash"
}

@test "plugins cmd-returned-notify: notify after elapsed time" {
	NOTIFY_IF_COMMAND_RETURNS_AFTER=0
	COMMAND_DURATION_START_SECONDS="$(_shell_duration_en)"
	export COMMAND_DURATION_START_SECONDS NOTIFY_IF_COMMAND_RETURNS_AFTER
	sleep 1
	run precmd_return_notification
	assert_success
	assert_output $'\a'
}

@test "plugins cmd-returned-notify: do not notify before elapsed time" {
	NOTIFY_IF_COMMAND_RETURNS_AFTER=10
	COMMAND_DURATION_START_SECONDS="$(_shell_duration_en)"
	export COMMAND_DURATION_START_SECONDS NOTIFY_IF_COMMAND_RETURNS_AFTER
	sleep 1
	run precmd_return_notification
	assert_success
	assert_output $''
}

@test "lib command_duration: preexec no output" {
	COMMAND_DURATION_START_SECONDS=
	run _command_duration_pre_exec
	assert_success
	assert_output ""
}
@test "lib command_duration: preexec set COMMAND_DURATION_START_SECONDS" {
	COMMAND_DURATION_START_SECONDS=
	assert_equal "${COMMAND_DURATION_START_SECONDS}" ""
	NOW="$(_shell_duration_en)"
	_command_duration_pre_exec
	# We need to make sure to account for nanoseconds...
	assert_equal "${COMMAND_DURATION_START_SECONDS%.*}" "${NOW%.*}"
}
