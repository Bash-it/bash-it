#!/usr/bin/env bash

THEME_PROMPT_SEPARATOR=""

SHELL_SSH_CHAR=" "
SHELL_THEME_PROMPT_COLOR=32
SHELL_THEME_PROMPT_COLOR_SUDO=202

VIRTUALENV_CHAR="ⓔ "
VIRTUALENV_THEME_PROMPT_COLOR=35

SCM_NONE_CHAR=""
SCM_GIT_CHAR=" "

SCM_THEME_PROMPT_CLEAN=""
SCM_THEME_PROMPT_DIRTY=""

SCM_THEME_PROMPT_COLOR=238
SCM_THEME_PROMPT_CLEAN_COLOR=231
SCM_THEME_PROMPT_DIRTY_COLOR=196
SCM_THEME_PROMPT_STAGED_COLOR=220
SCM_THEME_PROMPT_UNSTAGED_COLOR=166

CWD_THEME_PROMPT_COLOR=240

LAST_STATUS_THEME_PROMPT_COLOR=52

IN_VIM_PROMPT_COLOR=35
IN_VIM_PROMPT_TEXT="vim"


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

function powerline_shell_prompt {
    SHELL_PROMPT_COLOR=${SHELL_THEME_PROMPT_COLOR}
    if sudo -n uptime 2>&1 | grep -q "load"; then
        SHELL_PROMPT_COLOR=${SHELL_THEME_PROMPT_COLOR_SUDO}
    fi
    if [[ -n "${SSH_CLIENT}" ]]; then
        SHELL_PROMPT="${SHELL_SSH_CHAR}\u@\h"
    else
        SHELL_PROMPT="\u"
    fi
    SHELL_PROMPT="${bold_white}$(set_rgb_color - ${SHELL_PROMPT_COLOR}) ${SHELL_PROMPT} ${normal}"
    LAST_THEME_COLOR=${SHELL_PROMPT_COLOR}
}

function powerline_virtualenv_prompt {
    local environ=""

    if [[ -n "$CONDA_DEFAULT_ENV" ]]; then
        environ="conda: $CONDA_DEFAULT_ENV"
    elif [[ -n "$VIRTUAL_ENV" ]]; then
        environ=$(basename "$VIRTUAL_ENV")
    fi

    if [[ -n "$environ" ]]; then
        VIRTUALENV_PROMPT="$(set_rgb_color ${LAST_THEME_COLOR} ${VIRTUALENV_THEME_PROMPT_COLOR})${THEME_PROMPT_SEPARATOR}${normal}$(set_rgb_color - ${VIRTUALENV_THEME_PROMPT_COLOR}) ${VIRTUALENV_CHAR}$environ ${normal}"
        LAST_THEME_COLOR=${VIRTUALENV_THEME_PROMPT_COLOR}
    else
        VIRTUALENV_PROMPT=""
    fi
}

function powerline_scm_prompt {
    scm_prompt_vars

    if [[ "${SCM_NONE_CHAR}" != "${SCM_CHAR}" ]]; then
        if [[ "${SCM_DIRTY}" -eq 3 ]]; then
            SCM_PROMPT="$(set_rgb_color ${SCM_THEME_PROMPT_STAGED_COLOR} ${SCM_THEME_PROMPT_COLOR})"
        elif [[ "${SCM_DIRTY}" -eq 2 ]]; then
            SCM_PROMPT="$(set_rgb_color ${SCM_THEME_PROMPT_UNSTAGED_COLOR} ${SCM_THEME_PROMPT_COLOR})"
        elif [[ "${SCM_DIRTY}" -eq 1 ]]; then
            SCM_PROMPT="$(set_rgb_color ${SCM_THEME_PROMPT_DIRTY_COLOR} ${SCM_THEME_PROMPT_COLOR})"
        else
            SCM_PROMPT="$(set_rgb_color ${SCM_THEME_PROMPT_CLEAN_COLOR} ${SCM_THEME_PROMPT_COLOR})"
        fi
        if [[ "${SCM_GIT_CHAR}" == "${SCM_CHAR}" ]]; then
            SCM_PROMPT+=" ${SCM_CHAR}${SCM_BRANCH}${SCM_STATE}"
        fi
        SCM_PROMPT="$(set_rgb_color ${LAST_THEME_COLOR} ${SCM_THEME_PROMPT_COLOR})${THEME_PROMPT_SEPARATOR}${normal}${SCM_PROMPT} ${normal}"
        LAST_THEME_COLOR=${SCM_THEME_PROMPT_COLOR}
    else
        SCM_PROMPT=""
    fi
}

function powerline_cwd_prompt {
    CWD_PROMPT="$(set_rgb_color ${LAST_THEME_COLOR} ${CWD_THEME_PROMPT_COLOR})${THEME_PROMPT_SEPARATOR}${normal}$(set_rgb_color - ${CWD_THEME_PROMPT_COLOR}) \w ${normal}$(set_rgb_color ${CWD_THEME_PROMPT_COLOR} -)${normal}"
    LAST_THEME_COLOR=${CWD_THEME_PROMPT_COLOR}
}

function powerline_last_status_prompt {
    if [[ "$1" -eq 0 ]]; then
        LAST_STATUS_PROMPT="$(set_rgb_color ${LAST_THEME_COLOR} -)${THEME_PROMPT_SEPARATOR}${normal}"
    else
        LAST_STATUS_PROMPT="$(set_rgb_color ${LAST_THEME_COLOR} ${LAST_STATUS_THEME_PROMPT_COLOR})${THEME_PROMPT_SEPARATOR}${normal}$(set_rgb_color - ${LAST_STATUS_THEME_PROMPT_COLOR}) ${LAST_STATUS} ${normal}$(set_rgb_color ${LAST_STATUS_THEME_PROMPT_COLOR} -)${THEME_PROMPT_SEPARATOR}${normal}"
    fi
}

function powerline_in_vim_prompt {
  if [ -z "$VIMRUNTIME" ]; then
    IN_VIM_PROMPT=""
  else
    IN_VIM_PROMPT="$(set_rgb_color ${LAST_THEME_COLOR} ${IN_VIM_PROMPT_COLOR})${THEME_PROMPT_SEPARATOR}${normal}$(set_rgb_color - ${IN_VIM_PROMPT_COLOR}) ${IN_VIM_PROMPT_TEXT} ${normal}$(set_rgb_color ${IN_VIM_PROMPT_COLOR} -)${normal}"
    LAST_THEME_COLOR=${IN_VIM_PROMPT_COLOR}
  fi
}

function powerline_prompt_command() {
    local LAST_STATUS="$?"

    powerline_shell_prompt
    powerline_in_vim_prompt
    powerline_virtualenv_prompt
    powerline_scm_prompt
    powerline_cwd_prompt
    powerline_last_status_prompt LAST_STATUS

    PS1="${SHELL_PROMPT}${IN_VIM_PROMPT}${VIRTUALENV_PROMPT}${SCM_PROMPT}${CWD_PROMPT}${LAST_STATUS_PROMPT} "
}

safe_append_prompt_command powerline_prompt_command

