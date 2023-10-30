# shellcheck shell=bats

load "${MAIN_BASH_IT_DIR?}/test/test_helper.bash"

function local_setup_file() {
  setup_libs "command_duration"
  load "${BASH_IT?}/plugins/available/cmd-returned-notify.plugin.bash"
}

@test "plugins cmd-returned-notify: notify after elapsed time" {
	export NOTIFY_IF_COMMAND_RETURNS_AFTER=0
	export COMMAND_DURATION_START_SECONDS="$(_shell_duration_en)"
	sleep 1
	run precmd_return_notification
	assert_success
	assert_output $'\a'
}

@test "plugins cmd-returned-notify: do not notify before elapsed time" {
	export NOTIFY_IF_COMMAND_RETURNS_AFTER=10
	export COMMAND_DURATION_START_SECONDS="$(_shell_duration_en)"
	sleep 1
	run precmd_return_notification
	assert_success
	assert_output $''
}

@test "lib command_duration: preexec no output" {
	export COMMAND_DURATION_START_SECONDS=
	run _command_duration_pre_exec
	assert_success
	assert_output ""
}
@test "lib command_duration: preexec set COMMAND_DURATION_START_SECONDS" {
	export COMMAND_DURATION_START_SECONDS=
	assert_equal "${COMMAND_DURATION_START_SECONDS}" ""
	NOW="$(_shell_duration_en)"
	_command_duration_pre_exec
	# We need to make sure to account for nanoseconds...
	assert_equal "${COMMAND_DURATION_START_SECONDS%.*}" "${NOW%.*}"
}
