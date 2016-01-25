#!/usr/bin/env bash

THEME_PROMPT_SEPARATOR=""
THEME_PROMPT_LEFT_SEPARATOR=""

USER_INFO_SSH_CHAR=${USER_INFO_SSH_CHAR:=" "}
USER_INFO_THEME_PROMPT_COLOR=32
USER_INFO_THEME_PROMPT_COLOR_SUDO=202

VIRTUALENV_CHAR=${POWERLINE_VIRTUALENV_CHAR:="❲p❳ "}
CONDA_VIRTUALENV_CHAR=${POWERLINE_CONDA_VIRTUALENV_CHAR:="❲c❳ "}
VIRTUALENV_THEME_PROMPT_COLOR=35

SCM_NONE_CHAR=""
SCM_GIT_CHAR=${POWERLINE_SCM_GIT_CHAR:=" "}
PROMPT_CHAR=${POWERLINE_PROMPT_CHAR:="❯"}

SCM_THEME_PROMPT_CLEAN=""
SCM_THEME_PROMPT_DIRTY=""

SCM_THEME_PROMPT_CLEAN_COLOR=25
SCM_THEME_PROMPT_DIRTY_COLOR=88
SCM_THEME_PROMPT_STAGED_COLOR=30
SCM_THEME_PROMPT_UNSTAGED_COLOR=92
SCM_THEME_PROMPT_COLOR=${SCM_THEME_PROMPT_CLEAN_COLOR}

RVM_THEME_PROMPT_PREFIX=""
RVM_THEME_PROMPT_SUFFIX=""
RVM_THEME_PROMPT_COLOR=161
RVM_CHAR=${POWERLINE_RVM_CHAR:="❲r❳ "}

CWD_THEME_PROMPT_COLOR=240

LAST_STATUS_THEME_PROMPT_COLOR=196

CLOCK_THEME_PROMPT_COLOR=240

BATTERY_AC_CHAR="⚡"
BATTERY_STATUS_THEME_PROMPT_GOOD_COLOR=70
BATTERY_STATUS_THEME_PROMPT_LOW_COLOR=208
BATTERY_STATUS_THEME_PROMPT_CRITICAL_COLOR=160

THEME_PROMPT_CLOCK_FORMAT=${THEME_PROMPT_CLOCK_FORMAT:="%H:%M:%S"}

IN_VIM_PROMPT_COLOR=245
IN_VIM_PROMPT_TEXT="vim"

THEME_LEFT_SEGMENTS="scm virtualenv rvm cwd"
THEME_RIGHT_SEGMENTS="in_vim clock battery user_info"


function set_rgb_color {
    if [[ "${1}" != "-" ]]; then
        fg="38;5;${1}"
    fi
    if [[ "${2}" != "-" ]]; then
        bg="48;5;${2}"
        [[ -n "${fg}" ]] && bg=";${bg}"
    fi
    echo -e "\[\033[${fg}${bg}m\]"
}

function powerline_user_info_prompt {
    local offset=2
    local USER_INFO=""
    local USER_INFO_PROMPT=""
    USER_INFO_PROMPT_COLOR=${USER_INFO_THEME_PROMPT_COLOR}
    if sudo -n uptime 2>&1 | grep -q "load"; then
        USER_INFO_PROMPT_COLOR=${USER_INFO_THEME_PROMPT_COLOR_SUDO}
    fi
    case "${THEME_PROMPT_USER_INFO_MODE}" in
        "sudo")
            if [[ "${USER_INFO_PROMPT_COLOR}" == "${USER_INFO_THEME_PROMPT_COLOR_SUDO}" ]]; then
                USER_INFO="!"
            fi
            ;;
        *)
            if [[ -n "${SSH_CLIENT}" ]]; then
                USER_INFO="${USER_INFO_SSH_CHAR}${USER}@${HOSTNAME}"
            else
                USER_INFO="${USER}"
            fi
            ;;
    esac
    if [[ -n "${USER_INFO}" ]]; then
        if [[ "${SEGMENT_AT_RIGHT}" -eq 0 ]]; then
            USER_INFO_PROMPT="$(set_rgb_color ${USER_INFO_PROMPT_COLOR} -)${THEME_PROMPT_LEFT_SEPARATOR}${normal}"
        else
            USER_INFO_PROMPT="$(set_rgb_color ${USER_INFO_PROMPT_COLOR} ${LAST_THEME_COLOR})${THEME_PROMPT_LEFT_SEPARATOR}${normal}"
            (( offset += 1 ))
        fi
        USER_INFO_PROMPT+="$(set_rgb_color - ${USER_INFO_PROMPT_COLOR}) ${USER_INFO} ${normal}"
        RIGHT_PROMPT_LENGTH=$(( ${RIGHT_PROMPT_LENGTH} + ${#USER_INFO} + ${offset} ))
        LAST_THEME_COLOR=${USER_INFO_PROMPT_COLOR}
        RIGHT_PROMPT+="${USER_INFO_PROMPT}"
        (( SEGMENT_AT_RIGHT += 1 ))
    fi
}

function powerline_rvm_prompt {
    local RVM_PROMPT=""

    if command_exists rvm; then
        RVM_PROMPT=$(rvm_version_prompt)
        if [[ "${RVM_PROMPT}" != $(rvm strings default) ]]; then
            RVM_PROMPT="$(set_rgb_color - ${RVM_THEME_PROMPT_COLOR}) ${RVM_CHAR}${RVM_PROMPT} ${normal}"
            if [[ "${SEGMENT_AT_LEFT}" -gt 0 ]]; then
                RVM_PROMPT=$(set_rgb_color ${LAST_THEME_COLOR} ${RVM_THEME_PROMPT_COLOR})${THEME_PROMPT_SEPARATOR}${normal}${RVM_PROMPT}
            fi
            LAST_THEME_COLOR=${RVM_THEME_PROMPT_COLOR}
            LEFT_PROMPT+="${RVM_PROMPT}"
            (( SEGMENT_AT_LEFT += 1 ))
        fi
    fi
}

function powerline_virtualenv_prompt {
    local VIRTUALENV_PROMPT=""

    if [[ -n "$CONDA_DEFAULT_ENV" ]]; then
        VIRTUALENV_PROMPT="$CONDA_DEFAULT_ENV"
        VIRTUALENV_CHAR=${CONDA_VIRTUALENV_CHAR}
    elif [[ -n "$VIRTUAL_ENV" ]]; then
        VIRTUALENV_PROMPT=$(basename "$VIRTUAL_ENV")
    fi

    if [[ -n "$VIRTUALENV_PROMPT" ]]; then
        VIRTUALENV_PROMPT="$(set_rgb_color - ${VIRTUALENV_THEME_PROMPT_COLOR}) ${VIRTUALENV_CHAR}${VIRTUALENV_PROMPT} ${normal}"
        if [[ "${SEGMENT_AT_LEFT}" -gt 0 ]]; then
            VIRTUALENV_PROMPT=$(set_rgb_color ${LAST_THEME_COLOR} ${VIRTUALENV_THEME_PROMPT_COLOR})${THEME_PROMPT_SEPARATOR}${normal}${VIRTUALENV_PROMPT}
        fi
        LAST_THEME_COLOR=${VIRTUALENV_THEME_PROMPT_COLOR}
        LEFT_PROMPT+="${VIRTUALENV_PROMPT}"
        (( SEGMENT_AT_LEFT += 1 ))
    fi
}

function powerline_scm_prompt {
    local SCM_PROMPT=""

    scm_prompt_vars
    if [[ "${SCM_NONE_CHAR}" != "${SCM_CHAR}" ]]; then
        if [[ "${SCM_DIRTY}" -eq 3 ]]; then
            SCM_THEME_PROMPT_COLOR=${SCM_THEME_PROMPT_STAGED_COLOR}
        elif [[ "${SCM_DIRTY}" -eq 2 ]]; then
            SCM_THEME_PROMPT_COLOR=${SCM_THEME_PROMPT_UNSTAGED_COLOR}
        elif [[ "${SCM_DIRTY}" -eq 1 ]]; then
            SCM_THEME_PROMPT_COLOR=${SCM_THEME_PROMPT_DIRTY_COLOR}
        else
            SCM_THEME_PROMPT_COLOR=${SCM_THEME_PROMPT_CLEAN_COLOR}
        fi
        if [[ "${SCM_GIT_CHAR}" == "${SCM_CHAR}" ]]; then
            SCM_PROMPT+=" ${SCM_CHAR}${SCM_BRANCH}${SCM_STATE}"
        fi
        SCM_PROMPT="$(set_rgb_color - ${SCM_THEME_PROMPT_COLOR})${SCM_PROMPT} ${normal}"
        if [[ "${SEGMENT_AT_LEFT}" -gt 0 ]]; then
            SCM_PROMPT=$(set_rgb_color ${LAST_THEME_COLOR} ${SCM_THEME_PROMPT_COLOR})${THEME_PROMPT_SEPARATOR}${normal}${SCM_PROMPT}
        fi
        LEFT_PROMPT+="${SCM_PROMPT}"
        LAST_THEME_COLOR=${SCM_THEME_PROMPT_COLOR}
        (( SEGMENT_AT_LEFT += 1 ))
    fi
}

function powerline_cwd_prompt {
    local CWD_PROMPT=""
    #CWD_PROMPT="$(set_rgb_color - ${CWD_THEME_PROMPT_COLOR}) \w ${normal}$(set_rgb_color ${CWD_THEME_PROMPT_COLOR} -)${normal}$(set_rgb_color ${CWD_THEME_PROMPT_COLOR} -)${THEME_PROMPT_SEPARATOR}${normal}"
    CWD_PROMPT="$(set_rgb_color - ${CWD_THEME_PROMPT_COLOR}) \w ${normal}$(set_rgb_color ${CWD_THEME_PROMPT_COLOR} -)${normal}"
    if [[ "${SEGMENT_AT_LEFT}" -gt 0 ]]; then
        CWD_PROMPT=$(set_rgb_color ${LAST_THEME_COLOR} ${CWD_THEME_PROMPT_COLOR})${THEME_PROMPT_SEPARATOR}${normal}${CWD_PROMPT}
    fi
    LAST_THEME_COLOR=${CWD_THEME_PROMPT_COLOR}
    LEFT_PROMPT+="${CWD_PROMPT}"
    (( SEGMENT_AT_LEFT += 1 ))
}

function powerline_last_status_prompt {
    if [[ "$1" -eq 0 ]]; then
        LAST_STATUS_PROMPT=""
    else
        LAST_STATUS_PROMPT="$(set_rgb_color ${LAST_STATUS_THEME_PROMPT_COLOR} -) ${LAST_STATUS} ${normal}"
    fi
}

function powerline_clock_prompt {
    local offset=0
    local CLOCK=" $(date +"${THEME_PROMPT_CLOCK_FORMAT}") "

    if [[ $? -eq 0 ]]; then
        local CLOCK_PROMPT=""
        RIGHT_PROMPT_LENGTH=$(( ${RIGHT_PROMPT_LENGTH} + ${#CLOCK} ))
        if [[ "${SEGMENT_AT_RIGHT}" -eq 0 ]]; then
            CLOCK_PROMPT=$(set_rgb_color ${CLOCK_THEME_PROMPT_COLOR} -)
        else
            CLOCK_PROMPT=$(set_rgb_color ${CLOCK_THEME_PROMPT_COLOR} ${LAST_THEME_COLOR})
            (( offset += 1 ))
        fi
        CLOCK_PROMPT+=${THEME_PROMPT_LEFT_SEPARATOR}${normal}$(set_rgb_color - ${CLOCK_THEME_PROMPT_COLOR})${CLOCK}${normal}
        LAST_THEME_COLOR=${CLOCK_THEME_PROMPT_COLOR}
        RIGHT_PROMPT_LENGTH=$(( ${RIGHT_PROMPT_LENGTH} + ${offset} ))
        RIGHT_PROMPT+="${CLOCK_PROMPT}"
        (( SEGMENT_AT_RIGHT += 1 ))
    fi
}

function powerline_battery_prompt {
    local offset=3
    local BATTERY_STATUS="$(battery_percentage 2> /dev/null)"
    if [[ -z "${BATTERY_STATUS}" ]] || [[ "${BATTERY_STATUS}" = "-1" ]] || [[ "${BATTERY_STATUS}" = "no" ]]; then
        true
    else
        local BATTERY_PROMPT=""
        if [[ "$((10#${BATTERY_STATUS}))" -le 5 ]]; then
            BATTERY_STATUS_THEME_PROMPT_COLOR="${BATTERY_STATUS_THEME_PROMPT_CRITICAL_COLOR}"
        elif [[ "$((10#${BATTERY_STATUS}))" -le 25 ]]; then
            BATTERY_STATUS_THEME_PROMPT_COLOR="${BATTERY_STATUS_THEME_PROMPT_LOW_COLOR}"
        else
            BATTERY_STATUS_THEME_PROMPT_COLOR="${BATTERY_STATUS_THEME_PROMPT_GOOD_COLOR}"
        fi
        [[ "$(ac_adapter_connected)" ]] && BATTERY_STATUS="${BATTERY_AC_CHAR}${BATTERY_STATUS}"
        if [[ "${SEGMENT_AT_RIGHT}" -eq 0 ]]; then
            BATTERY_PROMPT=$(set_rgb_color ${BATTERY_STATUS_THEME_PROMPT_COLOR} -)${THEME_PROMPT_LEFT_SEPARATOR}${normal}
        else
            BATTERY_PROMPT=$(set_rgb_color ${BATTERY_STATUS_THEME_PROMPT_COLOR} ${LAST_THEME_COLOR})${THEME_PROMPT_LEFT_SEPARATOR}${normal}
            (( offset +=1 ))
        fi
        BATTERY_PROMPT+="$(set_rgb_color - ${BATTERY_STATUS_THEME_PROMPT_COLOR}) ${BATTERY_STATUS}% ${normal}"
        RIGHT_PROMPT_LENGTH=$(( ${RIGHT_PROMPT_LENGTH} + ${#BATTERY_STATUS} + ${offset} ))
        LAST_THEME_COLOR=${BATTERY_STATUS_THEME_PROMPT_COLOR}
        RIGHT_PROMPT+="${BATTERY_PROMPT}"
        (( SEGMENT_AT_RIGHT += 1 ))
    fi
}

function powerline_in_vim_prompt {
  local offset=2
  local IN_VIM_PROMPT=""
  if [ -n "$VIMRUNTIME" ]; then
    if [[ "${SEGMENT_AT_RIGHT}" -eq 0 ]]; then
      IN_VIM_PROMPT+="$(set_rgb_color ${IN_VIM_PROMPT_COLOR} -)${THEME_PROMPT_LEFT_SEPARATOR}${normal}"
    else
      IN_VIM_PROMPT+=$(set_rgb_color ${IN_VIM_PROMPT_COLOR} ${LAST_THEME_COLOR})${THEME_PROMPT_LEFT_SEPARATOR}${normal}
      (( offset += 1 ))
    fi
    IN_VIM_PROMPT+="$(set_rgb_color - ${IN_VIM_PROMPT_COLOR}) ${IN_VIM_PROMPT_TEXT} ${normal}"
    RIGHT_PROMPT_LENGTH=$(( ${RIGHT_PROMPT_LENGTH} + ${#IN_VIM_PROMPT_TEXT} + ${offset}))
    LAST_THEME_COLOR=${IN_VIM_PROMPT_COLOR}
    RIGHT_PROMPT+="${IN_VIM_PROMPT}"
    (( SEGMENT_AT_RIGHT += 1 ))
  fi
}


function powerline_prompt_command() {
    local LAST_STATUS="$?"
    local MOVE_CURSOR_RIGHTMOST='\033[500C'

    LEFT_PROMPT=""
    RIGHT_PROMPT=""
    SEGMENT_AT_LEFT=0
    SEGMENT_AT_RIGHT=0
    RIGHT_PROMPT_LENGTH=0
    LAST_THEME_COLOR=""

    ## left prompt ##
    for segment in $THEME_LEFT_SEGMENTS; do
        "powerline_${segment}_prompt"
    done
    [[ -n "${LEFT_PROMPT}" ]] && LEFT_PROMPT+="$(set_rgb_color ${LAST_THEME_COLOR} -)${THEME_PROMPT_SEPARATOR}${normal}"

    ## right prompt ##
    if [[ -n "${THEME_RIGHT_SEGMENTS}" ]]; then
        LEFT_PROMPT+="${MOVE_CURSOR_RIGHTMOST}"
        for segment in $THEME_RIGHT_SEGMENTS; do
            "powerline_${segment}_prompt"
        done
        LEFT_PROMPT+="\033[${RIGHT_PROMPT_LENGTH}D"
    fi

    powerline_last_status_prompt LAST_STATUS

    PS1="${LEFT_PROMPT}${RIGHT_PROMPT}\n${LAST_STATUS_PROMPT}${PROMPT_CHAR} "
}

PROMPT_COMMAND=powerline_prompt_command
