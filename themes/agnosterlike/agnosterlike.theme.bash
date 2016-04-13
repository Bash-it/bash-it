#!/usr/bin/env bash

# Based on the "powerline" theme
#
source ../powerline/powerline.theme.bash


THEME_PROMPT_SEPARATOR=""

SHELL_SSH_CHAR=""
SHELL_GEAR_CHAR="⚙"
SHELL_GEAR_CHAR_FORE=6
SHELL_THEME_PROMPT_COLOR=0
SHELL_THEME_PROMPT_COLOR_SUDO=3
SHELL_PROMPT_COLOR_FORE=7

SCM_THEME_PROMPT_COLOR=0
SCM_THEME_PROMPT_CLEAN_COLOR=2
SCM_THEME_PROMPT_DIRTY_COLOR=3
SCM_THEME_PROMPT_STAGED_COLOR=2
SCM_THEME_PROMPT_UNSTAGED_COLOR=2

CWD_THEME_PROMPT_COLOR=4


function powerline_shell_prompt {
  SHELL_PROMPT_COLOR=${SHELL_THEME_PROMPT_COLOR};
  SHELL_PROMPT_SYMBOLS="";
  if [[ "$USER" == "root" ]]; then
    SHELL_PROMPT_COLOR_FORE=${SHELL_THEME_PROMPT_COLOR_SUDO};
    SHELL_PROMPT_SYMBOLS="${SHELL_PROMPT_SYMBOLS}⚡ "; #  \u26a1
  fi;
  if [[ -n "${SSH_CLIENT}" ]]; then
    SHELL_PROMPT_SYMBOLS="${SHELL_PROMPT_SYMBOLS}${SHELL_SSH_CHAR} ";
  fi;
  if [[ $(jobs -l | wc -l) -gt 0 ]]; then
    SHELL_PROMPT_SYMBOLS="${SHELL_PROMPT_SYMBOLS}$(set_rgb_color ${SHELL_GEAR_CHAR_FORE} ${SHELL_PROMPT_COLOR})${SHELL_GEAR_CHAR} ";
  fi;
    SHELL_PROMPT="\u@\h";
  SHELL_PROMPT="$(set_rgb_color ${SHELL_PROMPT_COLOR_FORE} ${SHELL_PROMPT_COLOR}) ${SHELL_PROMPT_SYMBOLS}$(set_rgb_color ${SHELL_PROMPT_COLOR_FORE} ${SHELL_PROMPT_COLOR})${SHELL_PROMPT} ${normal}";
  LAST_THEME_COLOR=${SHELL_PROMPT_COLOR};
}

function powerline_scm_prompt {
  scm_prompt_vars;
  if [[ "${SCM_NONE_CHAR}" != "${SCM_CHAR}" ]]; then
    if [[ "${SCM_DIRTY}" -eq 3 ]]; then
      SCM_PROMPT="$(set_rgb_color ${SCM_THEME_PROMPT_COLOR} ${SCM_THEME_PROMPT_STAGED_COLOR})";
      SCM_LAST_THEME_COLOR=${SCM_THEME_PROMPT_STAGED_COLOR};
      SCM_THEICON=" ✚";
    else
      if [[ "${SCM_DIRTY}" -eq 2 ]]; then
        SCM_PROMPT="$(set_rgb_color ${SCM_THEME_PROMPT_COLOR} ${SCM_THEME_PROMPT_UNSTAGED_COLOR})";
        SCM_LAST_THEME_COLOR=${SCM_THEME_PROMPT_UNSTAGED_COLOR};
        SCM_THEICON=" ●";
      else
        if [[ "${SCM_DIRTY}" -eq 1 ]]; then
          SCM_PROMPT="$(set_rgb_color ${SCM_THEME_PROMPT_COLOR} ${SCM_THEME_PROMPT_DIRTY_COLOR})";
          SCM_LAST_THEME_COLOR=${SCM_THEME_PROMPT_DIRTY_COLOR};
          SCM_THEICON="";
        else
          SCM_PROMPT="$(set_rgb_color ${SCM_THEME_PROMPT_COLOR} ${SCM_THEME_PROMPT_CLEAN_COLOR})";
          SCM_LAST_THEME_COLOR=${SCM_THEME_PROMPT_CLEAN_COLOR};
          SCM_THEICON="";
        fi;
      fi;
    fi;
    if [[ "${SCM_GIT_CHAR}" == "${SCM_CHAR}" ]]; then # IS GIT
      if echo ${SCM_BRANCH} | grep -q "detached:"; then 
        SCM_CHAR="➦ " ;
        SCM_BRANCH=$(git status | head -n1 | sed -E 's/.+at //g');
      fi;
      SCM_PROMPT+=" ${SCM_CHAR}${SCM_BRANCH}${SCM_THEICON}";
    fi;
    SCM_PROMPT="$(set_rgb_color ${LAST_THEME_COLOR} ${SCM_LAST_THEME_COLOR})${THEME_PROMPT_SEPARATOR}${normal}${SCM_PROMPT} ${normal}";
    LAST_THEME_COLOR=${SCM_LAST_THEME_COLOR};
    unset SCM_LAST_THEME_COLOR;
  else
    SCM_PROMPT="";
  fi
}

function powerline_cwd_prompt {
  CWD_PROMPT="$(set_rgb_color ${LAST_THEME_COLOR} ${CWD_THEME_PROMPT_COLOR})${THEME_PROMPT_SEPARATOR}${normal}$(set_rgb_color 0 ${CWD_THEME_PROMPT_COLOR}) \w ${normal}";
  LAST_THEME_COLOR=${CWD_THEME_PROMPT_COLOR}
}

function powerline_prompt_command() {
  local LAST_STATUS="$?"

  powerline_shell_prompt
  powerline_in_vim_prompt
  powerline_virtualenv_prompt
  powerline_cwd_prompt
  powerline_scm_prompt
  powerline_last_status_prompt LAST_STATUS

  PS1="${SHELL_PROMPT}${IN_VIM_PROMPT}${VIRTUALENV_PROMPT}${CWD_PROMPT}${SCM_PROMPT}${LAST_STATUS_PROMPT} "
}

PROMPT_COMMAND=powerline_prompt_command

