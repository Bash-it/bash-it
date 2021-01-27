# shellcheck shell=bash

if [ -z "$BASH_IT_COMMAND_DURATION" ] || [ "$BASH_IT_COMMAND_DURATION" != true ]; then
	_command_duration() {
		echo -n
	}
	return
fi

# Define tmp dir and file
COMMAND_DURATION_TMPDIR="${TMPDIR:-/tmp}"
COMMAND_DURATION_FILE="${COMMAND_DURATION_FILE:-$COMMAND_DURATION_TMPDIR/bashit_theme_execution_$BASHPID}"

COMMAND_DURATION_ICON=${COMMAND_DURATION_ICON:-'  '}
COMMAND_DURATION_MIN_SECONDS=${COMMAND_DURATION_MIN_SECONDS:-'1'}

trap _command_duration_delete_temp_file EXIT HUP INT TERM

_command_duration_delete_temp_file() {
	if [[ -f "$COMMAND_DURATION_FILE" ]]; then
		rm -f "$COMMAND_DURATION_FILE"
	fi
}

_command_duration_pre_exec() {
	date +%s.%1N > "$COMMAND_DURATION_FILE"
}

_command_duration() {
	local command_duration command_start current_time
	local minutes seconds deciseconds
	local command_start_sseconds current_time_seconds command_start_deciseconds current_time_deciseconds
	current_time=$(date +%s.%1N)

	if [[ -f "$COMMAND_DURATION_FILE" ]]; then
		command_start=$(< "$COMMAND_DURATION_FILE")
		command_start_sseconds=${command_start%.*}
		current_time_seconds=${current_time%.*}

		command_start_deciseconds=$((10#${command_start#*.}))
		current_time_deciseconds=$((10#${current_time#*.}))

		# seconds
		command_duration=$((current_time_seconds - command_start_sseconds))

		if ((current_time_deciseconds >= command_start_deciseconds)); then
			deciseconds=$(((current_time_deciseconds - command_start_deciseconds)))
		else
			((command_duration -= 1))
			deciseconds=$((10 - ((command_start_deciseconds - current_time_deciseconds))))
		fi
		command rm "$COMMAND_DURATION_FILE"
	else
		command_duration=0
	fi

	if ((command_duration > 0)); then
		minutes=$((command_duration / 60))
		seconds=$((command_duration % 60))
	fi

	if ((minutes > 0)); then
		printf "%s%s%dm %ds" "$COMMAND_DURATION_ICON" "$COMMAND_DURATION_COLOR" "$minutes" "$seconds"
	elif ((seconds >= COMMAND_DURATION_MIN_SECONDS)); then
		printf "%s%s%d.%01ds" "$COMMAND_DURATION_ICON" "$COMMAND_DURATION_COLOR" "$seconds" "$deciseconds"
	fi
}

preexec_functions+=(_command_duration_pre_exec)
