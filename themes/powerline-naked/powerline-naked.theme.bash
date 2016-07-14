#!/usr/bin/env bash

THEME_PROMPT_SEPARATOR=""

SHELL_SSH_CHAR=" "
SHELL_THEME_PROMPT_COLOR=32
SHELL_SSH_THEME_PROMPT_COLOR=208

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

LAST_STATUS_THEME_PROMPT_COLOR=124

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
    if [[ -n "${SSH_CLIENT}" ]]; then
        SHELL_PROMPT="${bold_white} ${SHELL_SSH_CHAR}\u@\h ${normal}"
    else
        SHELL_PROMPT="${bold_white} \u ${normal}"
    fi
}

function powerline_virtualenv_prompt {
    local environ=""

    if [[ -n "$CONDA_DEFAULT_ENV" ]]; then
        environ="conda: $CONDA_DEFAULT_ENV"
    elif [[ -n "$VIRTUAL_ENV" ]]; then
        environ=$(basename "$VIRTUAL_ENV")
    fi

    if [[ -n "$environ" ]]; then
        VIRTUALENV_PROMPT="${THEME_PROMPT_SEPARATOR}$(set_rgb_color ${VIRTUALENV_THEME_PROMPT_COLOR} -) ${VIRTUALENV_CHAR}$environ ${normal}"
    else
        VIRTUALENV_PROMPT=""
    fi
}

function powerline_scm_prompt {
    scm_prompt_vars

    if [[ "${SCM_NONE_CHAR}" != "${SCM_CHAR}" ]]; then
        if [[ "${SCM_DIRTY}" -eq 3 ]]; then
            SCM_PROMPT="$(set_rgb_color ${SCM_THEME_PROMPT_STAGED_COLOR} -)"
        elif [[ "${SCM_DIRTY}" -eq 2 ]]; then
            SCM_PROMPT="$(set_rgb_color ${SCM_THEME_PROMPT_UNSTAGED_COLOR} -)"
        elif [[ "${SCM_DIRTY}" -eq 1 ]]; then
            SCM_PROMPT="$(set_rgb_color ${SCM_THEME_PROMPT_DIRTY_COLOR} -)"
        else
            SCM_PROMPT="$(set_rgb_color ${SCM_THEME_PROMPT_CLEAN_COLOR} -)"
        fi
        if [[ "${SCM_GIT_CHAR}" == "${SCM_CHAR}" ]]; then
            SCM_PROMPT+=" ${SCM_CHAR}${SCM_BRANCH}${SCM_STATE} "
        fi
        SCM_PROMPT="${THEME_PROMPT_SEPARATOR}${SCM_PROMPT}${normal}"
    else
        SCM_PROMPT=""
    fi
}

function powerline_cwd_prompt {
    CWD_PROMPT="${THEME_PROMPT_SEPARATOR} \w "
}

function powerline_last_status_prompt {
    if [[ "$1" -eq 0 ]]; then
        LAST_STATUS_PROMPT="${THEME_PROMPT_SEPARATOR}"
    else
        LAST_STATUS_PROMPT="${THEME_PROMPT_SEPARATOR}$(set_rgb_color ${LAST_STATUS_THEME_PROMPT_COLOR} -) ${LAST_STATUS} ${normal}${THEME_PROMPT_SEPARATOR}"
    fi
}

function powerline_prompt_command() {
    local LAST_STATUS="$?"

    powerline_shell_prompt
    powerline_virtualenv_prompt
    powerline_scm_prompt
    powerline_cwd_prompt
    powerline_last_status_prompt LAST_STATUS

    PS1="${SHELL_PROMPT}${VIRTUALENV_PROMPT}${SCM_PROMPT}${CWD_PROMPT}${LAST_STATUS_PROMPT} "
}

safe_append_prompt_command powerline_prompt_command

