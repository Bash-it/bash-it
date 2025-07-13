# shellcheck shell=bash
#
# Functions for measuring and reporting how long a command takes to run.

# Get shell duration in decimal format regardless of runtime locale.
# Notice: This function runs as a sub-shell - notice '(' vs '{'.
function _shell_duration_en() (
	# DFARREL You would think LC_NUMERIC would do it, but not working in my local.
	# Note: LC_ALL='en_US.UTF-8' has been used to enforce the decimal point to be
	# a period, but the specific locale 'en_US.UTF-8' is not ensured to exist in
	# the system.  One should instead use the locale 'C', which is ensured by the
	# C and POSIX standards.
	local LC_ALL=C
	printf "%s" "${EPOCHREALTIME:-$SECONDS}"
)

: "${COMMAND_DURATION_START_SECONDS:=$(_shell_duration_en)}"
: "${COMMAND_DURATION_ICON:=🕘}"
: "${COMMAND_DURATION_MIN_SECONDS:=1}"

function _command_duration_pre_exec() {
	COMMAND_DURATION_START_SECONDS="$(_shell_duration_en)"
}

function _command_duration_pre_cmd() {
	COMMAND_DURATION_START_SECONDS=""
}

function _dynamic_clock_icon {
	local clock_hand
	# clock hand value is between 90 and 9b in hexadecimal.
	# so between 144 and 155 in base 10.
	printf -v clock_hand '%x' $((((${1:-${SECONDS}} - 1) % 12) + 144))
	printf -v 'COMMAND_DURATION_ICON' '%b' "\xf0\x9f\x95\x$clock_hand"
}

function _command_duration() {
	[[ -n "${BASH_IT_COMMAND_DURATION:-}" ]] || return
	[[ -n "${COMMAND_DURATION_START_SECONDS:-}" ]] || return

	local command_duration=0 command_start="${COMMAND_DURATION_START_SECONDS:-0}"
	local -i minutes=0 seconds=0 deciseconds=0
	local -i command_start_seconds="${command_start%.*}"
	local -i command_start_deciseconds=$((10#${command_start##*.}))
	command_start_deciseconds="${command_start_deciseconds:0:1}"
	local current_time
	current_time="$(_shell_duration_en)"
	local -i current_time_seconds="${current_time%.*}"
	local -i current_time_deciseconds="$((10#${current_time##*.}))"
	current_time_deciseconds="${current_time_deciseconds:0:1}"

	if [[ "${command_start_seconds:-0}" -gt 0 ]]; then
		# seconds
		command_duration="$((current_time_seconds - command_start_seconds))"

		if ((current_time_deciseconds >= command_start_deciseconds)); then
			deciseconds="$((current_time_deciseconds - command_start_deciseconds))"
		else
			((command_duration -= 1))
			deciseconds="$((10 - (command_start_deciseconds - current_time_deciseconds)))"
		fi
	else
		command_duration=0
	fi

	if ((command_duration >= COMMAND_DURATION_MIN_SECONDS)); then
		minutes=$((command_duration / 60))
		seconds=$((command_duration % 60))

		_dynamic_clock_icon "${command_duration}"
		if ((minutes > 0)); then
			printf "%s %s%dm %ds" "${COMMAND_DURATION_ICON:-}" "${COMMAND_DURATION_COLOR:-}" "$minutes" "$seconds"
		else
			printf "%s %s%d.%01ds" "${COMMAND_DURATION_ICON:-}" "${COMMAND_DURATION_COLOR:-}" "$seconds" "$deciseconds"
		fi
	fi
}

_bash_it_library_finalize_hook+=("safe_append_preexec '_command_duration_pre_exec'")
_bash_it_library_finalize_hook+=("safe_append_prompt_command '_command_duration_pre_cmd'")
