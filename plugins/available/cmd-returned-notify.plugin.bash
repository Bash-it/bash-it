cite about-plugin
about-plugin 'Alert (BEL) when process ends after a threshold of seconds'


precmd_return_notification() {
    LAST_COMMAND_DURATION=$(expr $(date +%s) - ${LAST_COMMAND_TIME:=$(date +%s)})
    [[ ${LAST_COMMAND_DURATION} -gt ${NOTIFY_IF_COMMAND_RETURNS_AFTER} ]] && echo -e "\a"
    LAST_COMMAND_TIME=
}

preexec_return_notification() {
    [ -z "${LAST_COMMAND_TIME}" ]  && LAST_COMMAND_TIME=$(date +%s)
}

precmd_functions+=(precmd_return_notification)
preexec_functions+=(preexec_return_notification)
