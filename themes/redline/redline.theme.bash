#!/usr/bin/env bash

. "$BASH_IT/themes/powerline/powerline.base.bash"

#PROMPT_DISTRO_LOGO="💻"
PROMPT_DISTRO_LOGO_COLOR=15
PROMPT_DISTRO_LOGO_COLORBG=52

PROMPT_CHAR=${POWERLINE_PROMPT_CHAR:=""}
POWERLINE_LEFT_SEPARATOR=${POWERLINE_LEFT_SEPARATOR:=""}

USER_INFO_SSH_CHAR=${POWERLINE_USER_INFO_SSH_CHAR:=" "}
USER_INFO_SUDO_CHAR=${POWERLINE_USER_INFO_SUDO_CHAR:=" "}
USER_INFO_THEME_PROMPT_COLOR=52
USER_INFO_THEME_PROMPT_COLOR_SUDO=52

PYTHON_VENV_CHAR=${POWERLINE_PYTHON_VENV_CHAR:="❲p❳ "}
CONDA_PYTHON_VENV_CHAR=${POWERLINE_CONDA_PYTHON_VENV_CHAR:="❲c❳ "}
PYTHON_VENV_THEME_PROMPT_COLOR=23

SCM_NONE_CHAR=""
SCM_GIT_CHAR=${POWERLINE_SCM_GIT_CHAR:=" "}
SCM_HG_CHAR=${POWERLINE_SCM_HG_CHAR:="☿ "}
SCM_THEME_PROMPT_CLEAN=""
SCM_THEME_PROMPT_DIRTY=""
SCM_THEME_PROMPT_CLEAN_COLOR=235
SCM_THEME_PROMPT_DIRTY_COLOR=235 #124
SCM_THEME_PROMPT_STAGED_COLOR=235 #52
SCM_THEME_PROMPT_UNSTAGED_COLOR=88
SCM_THEME_PROMPT_COLOR=${SCM_THEME_PROMPT_CLEAN_COLOR}

RVM_THEME_PROMPT_PREFIX=""
RVM_THEME_PROMPT_SUFFIX=""
RBENV_THEME_PROMPT_PREFIX=""
RBENV_THEME_PROMPT_SUFFIX=""
RUBY_THEME_PROMPT_COLOR=161
RUBY_CHAR=${POWERLINE_RUBY_CHAR:="❲r❳ "}

CWD_THEME_DIR_SEPARATOR=""
CWD_THEME_DIR_SEPARATOR_COLOR=52

CWD_THEME_PROMPT_COLOR=238
HOST_THEME_PROMPT_COLOR=88

LAST_STATUS_THEME_PROMPT_COLOR=52

CLOCK_THEME_PROMPT_COLOR=240

BATTERY_AC_CHAR=${BATTERY_AC_CHAR:="⚡"}
BATTERY_STATUS_THEME_PROMPT_GOOD_COLOR=70
BATTERY_STATUS_THEME_PROMPT_LOW_COLOR=208
BATTERY_STATUS_THEME_PROMPT_CRITICAL_COLOR=160

THEME_CLOCK_FORMAT=${THEME_CLOCK_FORMAT:="%H:%M:%S"}

IN_VIM_THEME_PROMPT_COLOR=245
IN_VIM_THEME_PROMPT_TEXT="vim"

#POWERLINE_PROMPT=${POWERLINE_PROMPT:="python_venv ruby user_info hostname cwd scm"}
POWERLINE_PROMPT=${POWERLINE_PROMPT:="user_info scm python_venv ruby cwd"}


safe_append_prompt_command __powerline_prompt_command
