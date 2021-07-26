# shellcheck shell=bash

if [[ "${BASH_IT_COMMAND_DURATION:-false}" != true ]]; then
	_command_duration() {
		echo -n
	}
	return
fi

COMMAND_DURATION_START_TIME=

COMMAND_DURATION_ICON=${COMMAND_DURATION_ICON:-'  '}
COMMAND_DURATION_MIN_SECONDS=${COMMAND_DURATION_MIN_SECONDS:-'1'}

_command_duration_pre_exec() {
	local command_nano_now="$(date +%1N)"
	[[ "$command_nano_now" == "1N" ]] && command_nano_now=1
	COMMAND_DURATION_START_TIME="$(date "+%s").${command_nano_now}"
}

_command_duration() {
	local command_duration command_start current_time
	local minutes seconds deciseconds
	local command_start_sseconds current_time_seconds command_start_deciseconds current_time_deciseconds
	local command_nano_now="$(date +%1N)"
	[[ "$command_nano_now" == "1N" ]] && command_nano_now=1
	current_time="$(date "+%s").${command_nano_now}"

	if [[ -n "${COMMAND_DURATION_START_TIME:-}" ]]; then
		_bash_it_log_section="command_duration" _log_debug "calculating start time"
		command_start_sseconds=${COMMAND_DURATION_START_TIME%.*}
		current_time_seconds=${current_time%.*}

		command_start_deciseconds=$((10#${command_start#*.}))
		current_time_deciseconds=$((10#${current_time#*.}))

		# seconds
		command_duration=$((current_time_seconds - command_start_sseconds))
		_bash_it_log_section="command_duration" _log_debug "duration: $command_duration (from $COMMAND_DURATION_START_TIME to $current_time)"

		if ((current_time_deciseconds >= command_start_deciseconds)); then
			deciseconds=$(((current_time_deciseconds - command_start_deciseconds)))
		else
			((command_duration -= 1))
			deciseconds=$((10 - ((command_start_deciseconds - current_time_deciseconds))))
		fi
	else
		command_duration=0
	fi

	if ((command_duration > 0)); then
		_bash_it_log_section="command_duration" _log_debug "calculating minutes and seconds"
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
