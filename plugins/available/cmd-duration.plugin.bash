cite about-plugin
about-plugin 'keep track of the moment when the last command started, to be able to compute its duration'

# Define tmp dir and file
COMMAND_DURATION_TMPDIR="${TMPDIR:-/tmp}"
COMMAND_DURATION_FILE="$COMMAND_DURATION_TMPDIR/bashit_theme_execution_$BASHPID"

COMMAND_DURATION_ICON='  '

trap _command_duration_delete_temp_file EXIT HUP INT TERM

_command_duration_delete_temp_file() {
    if [[ -f "$COMMAND_DURATION_FILE" ]]; then
        rm -f "$COMMAND_DURATION_FILE"
    fi
}

_command_duration_pre_exec() {
    date +%s > "$COMMAND_DURATION_FILE"
}

_command_duration() {
    local command_duration command_start current_time
    current_time=$(date +%s)

    if [[ -f "$COMMAND_DURATION_FILE" ]]; then
        command_start=$(< "$COMMAND_DURATION_FILE")
        command_duration=$(( current_time - command_start ))
        command rm "$COMMAND_DURATION_FILE"
    else
        command_duration=0
    fi

    if [[ "$command_duration" -gt 0 ]]; then
        timer_m=$(( command_duration / 60 ))
        timer_s=$(( command_duration % 60 ))
    fi

    if [[ "$timer_m" -gt 0 ]]; then
        echo "${COMMAND_DURATION_COLOR}$COMMAND_DURATION_ICON$normal${timer_m}m ${timer_s}s"
    elif [[ "$timer_s" -gt 0 ]]; then
        echo "${COMMAND_DURATION_COLOR}$COMMAND_DURATION_ICON$normal${timer_s}s"
    fi
}

preexec() (
    _command_duration_pre_exec
)

preexec_install
