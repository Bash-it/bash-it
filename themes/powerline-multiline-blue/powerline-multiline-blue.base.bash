# Define this here so it can be used by all of the Powerline themes
THEME_CHECK_SUDO=${THEME_CHECK_SUDO:=true}

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

function __powerline_user_info_prompt {
  local user_info=""
  local color=${USER_INFO_THEME_PROMPT_COLOR}

  if [[ "${THEME_CHECK_SUDO}" = true ]]; then
    if sudo -n uptime 2>&1 | grep -q "load"; then
      color=${USER_INFO_THEME_PROMPT_COLOR_SUDO}
    fi
  fi

  case "${POWERLINE_PROMPT_USER_INFO_MODE}" in
    "sudo")
      if [[ "${color}" = "${USER_INFO_THEME_PROMPT_COLOR_SUDO}" ]]; then
        user_info="!"
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
  [[ -n "${user_info}" ]] && echo "${user_info}|${color}"
}

function __powerline_ruby_prompt {
  local ruby_version=""

  if _command_exists rvm; then
    ruby_version="$(rvm_version_prompt)"
  elif _command_exists rbenv; then
    ruby_version=$(rbenv_version_prompt)
  fi

  [[ -n "${ruby_version}" ]] && echo "${RUBY_CHAR}${ruby_version}|${RUBY_THEME_PROMPT_COLOR}"
}

function __powerline_k8s_context_prompt {
  local kubernetes_context=""

  if _command_exists kubectl; then
    kubernetes_context="$(k8s_context_prompt)"
  fi

  [[ -n "${kubernetes_context}" ]] && echo "${KUBERNETES_CONTEXT_THEME_CHAR}${kubernetes_context}|${KUBERNETES_CONTEXT_THEME_PROMPT_COLOR}"
}

function __powerline_python_venv_prompt {
  set +u
  local python_venv=""
  local python_version=""

  if [[ -n "${CONDA_DEFAULT_ENV}" ]]; then
    python_venv="${CONDA_DEFAULT_ENV}"
    PYTHON_VENV_CHAR=${CONDA_PYTHON_VENV_CHAR}
  elif [[ -n "${VIRTUAL_ENV}" ]]; then
    python_venv=$(basename "${VIRTUAL_ENV}")
  fi

  python_version="$(python -V 2>&1 | grep -o -E '[0-9\.]+' | cut -d'.' -f1,2)"

  # [[ -n "${python_venv}" ]] && echo "${PYTHON_VENV_CHAR}${python_venv}|${PYTHON_VENV_THEME_PROMPT_COLOR}"
  [[ -n "${python_venv}" ]] && echo "Py${python_version}|${PYTHON_VENV_THEME_PROMPT_COLOR}"
}

function __powerline_scm_prompt {
  local color=""
  local scm_prompt=""

  scm_prompt_vars

  if [[ "${SCM_NONE_CHAR}" != "${SCM_CHAR}" ]]; then
    SCM_BRANCH=$(_git-friendly-ref)
    if [[ "${SCM_DIRTY}" -eq 3 ]]; then
      color=${SCM_THEME_PROMPT_STAGED_COLOR}
      scm_prompt+="${SCM_CHAR}${SCM_BRANCH} ●"
    elif [[ "${SCM_DIRTY}" -eq 2 ]]; then
      color=${SCM_THEME_PROMPT_UNSTAGED_COLOR}
      scm_prompt+="${SCM_CHAR}${SCM_BRANCH} ✚"
    elif [[ "${SCM_DIRTY}" -eq 1 ]]; then
      color=${SCM_THEME_PROMPT_DIRTY_COLOR}
      scm_prompt+="${SCM_CHAR}${SCM_BRANCH} ⋯" # …
    else
      color=${SCM_THEME_PROMPT_CLEAN_COLOR}
      scm_prompt+="${SCM_CHAR}${SCM_BRANCH}"
    fi
    echo "$(eval "echo ${scm_prompt}")${scm}|${color}"
  fi
}

function __powerline_cwd_prompt {
  local pwd=${PWD//$HOME/\~}
  #pwd_list=(${pwd//\// })
  IFS='/' read -a pwd_list <<< "${pwd}"
  list_len=${#pwd_list[@]}

  if [[ $list_len -le 1 ]]; then
    cwd=$pwd
  else 
    if [[ ${pwd_list[0]} != '~' ]]; then
      cwd='/'
    fi

    firstchar=$(echo ${pwd_list[0]} | cut -c1)
    if [[ $firstchar == '.' ]] ; then
      firstchar=$(echo ${pwd_list[0]} | cut -c1,2)
    fi

    cwd=${cwd}$firstchar

    for ((i=1; i < $list_len; i++)) do
      if [[ $((i + 1 )) != ${list_len} ]]; then

        firstchar=$(echo ${pwd_list[$i]} | cut -c1)
        if [[ $firstchar == '.' ]] ; then
          firstchar=$(echo ${pwd_list[$i]} | cut -c1,2)
        fi

        cwd=${cwd}/$firstchar
      else
        cwd=${cwd}/${pwd_list[$i]}
      fi
    done
  fi

  echo "${cwd}|${CWD_THEME_PROMPT_COLOR}"
}

function __powerline_hostname_prompt {
    echo "$(hostname -s)|${HOST_THEME_PROMPT_COLOR}"
}

function __powerline_wd_prompt {
  echo "\W|${CWD_THEME_PROMPT_COLOR}"
}

function __powerline_clock_prompt {
  echo "$(date +"${THEME_CLOCK_FORMAT}")|${CLOCK_THEME_PROMPT_COLOR}"
}

function __powerline_battery_prompt {
  local color=""
  local battery_status="$(battery_percentage 2> /dev/null)"

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
    echo "${battery_status}%|${color}"
  fi
}

function __powerline_in_vim_prompt {
  if [ -n "$VIMRUNTIME" ]; then
    echo "${IN_VIM_THEME_PROMPT_TEXT}|${IN_VIM_THEME_PROMPT_COLOR}"
  fi
}

function __powerline_aws_profile_prompt {
  if [[ -n "${AWS_PROFILE}" ]]; then
    echo "${AWS_PROFILE_CHAR}${AWS_PROFILE}|${AWS_PROFILE_PROMPT_COLOR}"
  fi
}

function __powerline_last_status_prompt {
  # [[ "$1" -ne 0 ]] && echo "${1}|${LAST_STATUS_THEME_PROMPT_COLOR}"
  [[ "$1" -ne 0 ]] && echo "$(set_color ${LAST_STATUS_THEME_PROMPT_COLOR} -) ! $(set_color ${HOST_THEME_PROMPT_COLOR} ${CWD_THEME_PROMPT_COLOR})${separator_char}${normal}"
}

function __powerline_left_segment {
  local OLD_IFS="${IFS}"; IFS="|"
  local params=( $1 )
  IFS="${OLD_IFS}"
  local separator_char="${POWERLINE_LEFT_SEPARATOR}"
  local separator=""

  if [[ "${SEGMENTS_AT_LEFT}" -gt 0 ]]; then
    separator="$(set_color ${LAST_SEGMENT_COLOR} ${params[1]})${separator_char}${normal}"
  fi
  LEFT_PROMPT+="${separator}$(set_color ${FG_COLOR} ${params[1]}) ${params[0]} ${normal}"
  LAST_SEGMENT_COLOR=${params[1]}
  (( SEGMENTS_AT_LEFT += 1 ))
}

function __powerline_right_segment {
  local OLD_IFS="${IFS}"; IFS="|"
  local params=( $1 )
  IFS="${OLD_IFS}"
  local separator_char="${POWERLINE_RIGHT_SEPARATOR}"
  local padding="${POWERLINE_PADDING}"
  local separator_color=""

  if [[ "${SEGMENTS_AT_RIGHT}" -eq 0 ]]; then
    separator_char="${POWERLINE_RIGHT_END}"
    separator_color="$(set_color ${params[1]} -)"
  else
    separator_color="$(set_color ${params[1]} ${LAST_SEGMENT_COLOR})"
    (( padding += 1 ))
  fi
  RIGHT_PROMPT+="${separator_color}${separator_char}${normal}$(set_color - ${params[1]}) ${params[0]} ${normal}$(set_color - ${COLOR})${normal}"
  RIGHT_PROMPT_LENGTH=$(( ${#params[0]} + RIGHT_PROMPT_LENGTH + padding ))
  LAST_SEGMENT_COLOR="${params[1]}"
  (( SEGMENTS_AT_RIGHT += 1 ))
}

function __powerline_prompt_command {
  local last_status="$?" ## always the first
  local separator_char="${POWERLINE_LEFT_SEPARATOR}"
  local move_cursor_rightmost='\033[500C'

  LEFT_PROMPT=""
  RIGHT_PROMPT=""
  RIGHT_PROMPT_LENGTH=0
  SEGMENTS_AT_LEFT=0
  SEGMENTS_AT_RIGHT=0
  LAST_SEGMENT_COLOR=""

  ## left prompt ##
  [[ "${last_status}" -ne 0 ]] && LEFT_PROMPT+="$(set_color ${LAST_SEGMENT_COLOR} -)$(__powerline_last_status_prompt ${last_status})${normal}"
  for segment in $POWERLINE_LEFT_PROMPT; do
    local info="$(__powerline_${segment}_prompt)"
    [[ -n "${info}" ]] && __powerline_left_segment "${info}"
  done
  [[ -n "${LEFT_PROMPT}" ]] && LEFT_PROMPT+="$(set_color ${LAST_SEGMENT_COLOR} -)${POWERLINE_LEFT_END}${normal}"

  ## right prompt ##
  if [[ -n "${POWERLINE_RIGHT_PROMPT}" ]]; then
    # LEFT_PROMPT+="${move_cursor_rightmost}"
    if [[ ${POWERLINE_RIGHT_PROMPT} == *"date"* ]]; then
      clock="$(date +"${THEME_CLOCK_FORMAT}")$([[ $(echo "${POWERLINE_RIGHT_PROMPT}" | wc -w) -gt 1 ]] && echo " ")"
      RIGHT_PROMPT+="$(set_color ${CLOCK_COLOR} -)${clock}${normal}"
      RIGHT_PROMPT_LENGTH=${#clock}
    fi
    for segment in $POWERLINE_RIGHT_PROMPT; do
      [[ ${segment} == "date" ]] && continue
      local info="$(__powerline_${segment}_prompt)"
      [[ -n "${info}" ]] && __powerline_right_segment "${info}"
    done
    RIGHT_PAD=$(printf "%.s " $(seq 1 $RIGHT_PROMPT_LENGTH))
    LEFT_PROMPT+="${RIGHT_PAD}${move_cursor_rightmost}"
    LEFT_PROMPT+="\033[${RIGHT_PROMPT_LENGTH}D"
  fi

  #PS1="${LEFT_PROMPT}${RIGHT_PROMPT}\n${PROMPT_CHAR} "
  PS1="${LEFT_PROMPT}${RIGHT_PROMPT}\n${PROMPT_CHAR} "

  ## cleanup ##
  unset LAST_SEGMENT_COLOR \
        LEFT_PROMPT RIGHT_PROMPT RIGHT_PROMPT_LENGTH \
        SEGMENTS_AT_LEFT SEGMENTS_AT_RIGHT
}
