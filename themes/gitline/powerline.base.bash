# Sudo check after every command
THEME_CHECK_SUDO=${THEME_CHECK_SUDO:=true}

#To set color for foreground and background
function set_color {
  set +u
  if [[ "${1}" != "-" ]]; then
    fg="38;5;${1}"
  fi
  if [[ "${2}" != "-" ]]; then
    bg="48;5;${2}"
    [[ -n "${fg}" ]] && bg=";${bg}"
  fi
  echo -e "\[\033[${fg}${bg}m\]"
}

#Customising User Info Segment
function __powerline_user_info_prompt {
  local user_info="${USER}"
  local color=${USER_INFO_THEME_PROMPT_COLOR}
  local fg_color=15

  if [[ "${THEME_CHECK_SUDO}" = true ]]; then
    if sudo -n uptime 2>&1 | grep -q "load"; then
      color=${USER_INFO_THEME_PROMPT_COLOR_SUDO}
    fi
  fi

  case "${POWERLINE_PROMPT_USER_INFO_MODE}" in
    "sudo")
      if [[ "${color}" = "${USER_INFO_THEME_PROMPT_COLOR_SUDO}" ]]; then
        user_info="👑 ${USER}"
        fg_color=227
        color=${USER_INFO_THEME_PROMPT_COLOR_SUDO}
      fi
      ;;
    *)
      if [[ -n "${SSH_CLIENT}" ]] || [[ -n "${SSH_CONNECTION}" ]]; then
        user_info="${USER_INFO_SSH_CHAR}${USER}"
      else
        user_info="${USER}"
      fi
      ;;
  esac
  [[ -n "${user_info}" ]] && echo "${user_info}|${color}|${fg_color}"
}

#Customising Ruby Prompt
function __powerline_ruby_prompt {
  local ruby_version=""
  local fg_color=206

  if _command_exists rvm; then
    ruby_version="$(rvm_version_prompt)"
  elif _command_exists rbenv; then
    ruby_version=$(rbenv_version_prompt)
  fi

  [[ -n "${ruby_version}" ]] && echo "${RUBY_CHAR}${ruby_version}|${RUBY_THEME_PROMPT_COLOR}|${fg_color}"
}

#Customising Python (venv) Prompt
function __powerline_python_venv_prompt {
  set +u
  local python_venv=""
  local fg_color=206

  if [[ -n "${CONDA_DEFAULT_ENV}" ]]; then
    python_venv="${CONDA_DEFAULT_ENV}"
    PYTHON_VENV_CHAR=${CONDA_PYTHON_VENV_CHAR}
  elif [[ -n "${VIRTUAL_ENV}" ]]; then
    python_venv=$(basename "${VIRTUAL_ENV}")
  fi

  [[ -n "${python_venv}" ]] && echo "${PYTHON_VENV_CHAR}${python_venv}|${PYTHON_VENV_THEME_PROMPT_COLOR}|${fg_color}"
}

#Customising SCM(GIT) Prompt
function __powerline_scm_prompt {
  local color=""
  local scm_prompt=""
  local fg_color=206

  scm_prompt_vars


  if [[ "${SCM_NONE_CHAR}" != "${SCM_CHAR}" ]]; then
    if [[ "${SCM_DIRTY}" -eq 3 ]]; then
      color=${SCM_THEME_PROMPT_STAGED_COLOR}
      fg_color=124
    elif [[ "${SCM_DIRTY}" -eq 2 ]]; then
      color=${SCM_THEME_PROMPT_UNSTAGED_COLOR}
      fg_color=56
    elif [[ "${SCM_DIRTY}" -eq 1 ]]; then
      color=${SCM_THEME_PROMPT_DIRTY_COLOR}
      fg_color=118
    elif [[ "${SCM_DIRTY}" -eq 0 ]]; then
      color=${SCM_THEME_PROMPT_CLEAN_COLOR}
      fg_color=16
    else
      color=${SCM_THEME_PROMPT_COLOR}
      fg_color=255
    fi
    if [[ "${SCM_GIT_CHAR}" == "${SCM_CHAR}" ]]; then
      scm_prompt+="${SCM_CHAR}${SCM_BRANCH}${SCM_STATE}"
    elif [[ "${SCM_P4_CHAR}" == "${SCM_CHAR}" ]]; then
      scm_prompt+="${SCM_CHAR}${SCM_BRANCH}${SCM_STATE}"
    elif [[ "${SCM_HG_CHAR}" == "${SCM_CHAR}" ]]; then
      scm_prompt+="${SCM_CHAR}${SCM_BRANCH}${SCM_STATE}"
    fi
    echo "${scm_prompt}${scm}|${color}|${fg_color}"
  fi
}

function __powerline_cwd_prompt {
  local cwd=$(pwd | sed "s|^${HOME}|~|")
  local fg_color=16

  echo "${cwd}|${CWD_THEME_PROMPT_COLOR}|${fg_color}"
}

function __powerline_hostname_prompt {
    local fg_color=206

    echo "$(hostname -s)|${HOST_THEME_PROMPT_COLOR}|${fg_color}"
}

function __powerline_wd_prompt {
    local fg_color=206

  echo "\W|${CWD_THEME_PROMPT_COLOR}|${fg_color}"
}

function __powerline_clock_prompt {
    local fg_color=206

  echo "$(date +"${THEME_CLOCK_FORMAT}")|${CLOCK_THEME_PROMPT_COLOR}|${fg_color}"
}

function __powerline_battery_prompt {
  local color=""
  local battery_status="$(battery_percentage 2> /dev/null)"
  local fg_color=255

  if [[ -z "${battery_status}" ]] || [[ "${battery_status}" = "-1" ]] || [[ "${battery_status}" = "no" ]]; then
    true
  else
    if [[ "$((10#${battery_status}))" -le 5 ]]; then
      color="${BATTERY_STATUS_THEME_PROMPT_CRITICAL_COLOR}"
    elif [[ "$((10#${battery_status}))" -le 25 ]]; then
      color="${BATTERY_STATUS_THEME_PROMPT_LOW_COLOR}"
    else
      color="${BATTERY_STATUS_THEME_PROMPT_GOOD_COLOR}"
    fi
    ac_adapter_connected && battery_status="${BATTERY_AC_CHAR}${battery_status}"
    echo "${battery_status}%|${color}|${fg_color}"
  fi
}

function __powerline_in_vim_prompt {
    local fg_color=206

  if [ -n "$VIMRUNTIME" ]; then
    echo "${IN_VIM_THEME_PROMPT_TEXT}|${IN_VIM_THEME_PROMPT_COLOR}|${fg_color}"
  fi
}

function __powerline_aws_profile_prompt {
    local fg_color=206

  if [[ -n "${AWS_PROFILE}" ]]; then
    echo "${AWS_PROFILE_CHAR}${AWS_PROFILE}|${AWS_PROFILE_PROMPT_COLOR}|${fg_color}"
  fi
}

function __powerline_left_segment {
  local OLD_IFS="${IFS}"; IFS="|"
  local params=( $1 )
  IFS="${OLD_IFS}"
  local separator_char="${POWERLINE_LEFT_SEPARATOR}"
  local separator=""
  local fg_color=206

  #for seperator character
  if [[ "${SEGMENTS_AT_LEFT}" -gt 0 ]]; then
    separator="$(set_color ${LAST_SEGMENT_COLOR} ${params[1]})${separator_char}${normal}"
  fi
  #change here to cahnge fg color
  LEFT_PROMPT+="${separator}$(set_color ${params[2]} ${params[1]}) ${params[0]} ${normal}"
  #seperator char color = current bg
  LAST_SEGMENT_COLOR=${params[1]}
  (( SEGMENTS_AT_LEFT += 1 ))
}

function __powerline_last_status_prompt {
  [[ "$1" -ne 0 ]] && echo "${1}|${LAST_STATUS_THEME_PROMPT_COLOR}"
}

function __powerline_prompt_command {
  local last_status="$?" ## always the first
  local separator_char="${POWERLINE_PROMPT_CHAR}"

  LEFT_PROMPT=""
  SEGMENTS_AT_LEFT=0
  LAST_SEGMENT_COLOR=""


  if [[ -n "${POWERLINE_PROMPT_DISTRO_LOGO}" ]]; then
      LEFT_PROMPT+="$(set_color ${PROMPT_DISTRO_LOGO_COLOR} ${PROMPT_DISTRO_LOGO_COLORBG})${PROMPT_DISTRO_LOGO}$(set_color - -)"
  fi

  ## left prompt ##
  for segment in $POWERLINE_PROMPT; do
    local info="$(__powerline_${segment}_prompt)"
    [[ -n "${info}" ]] && __powerline_left_segment "${info}"
  done

  [[ "${last_status}" -ne 0 ]] && __powerline_left_segment $(__powerline_last_status_prompt ${last_status})
  [[ -n "${LEFT_PROMPT}" ]] && LEFT_PROMPT+="$(set_color ${LAST_SEGMENT_COLOR} -)${separator_char}${normal}"

  PS1="${LEFT_PROMPT} "

  ## cleanup ##
  unset LAST_SEGMENT_COLOR \
        LEFT_PROMPT \
        SEGMENTS_AT_LEFT
}

