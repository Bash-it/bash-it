# Define this here so it can be used by all of the Powerline themes

. "$BASH_IT/themes/powerline-multiline/powerline-multiline.base.bash"

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
      scm_prompt+="${SCM_CHAR}${SCM_BRANCH} ⋯"
    else
      color=${SCM_THEME_PROMPT_CLEAN_COLOR}
      scm_prompt+="${SCM_CHAR}${SCM_BRANCH}"
    fi
    echo "$(eval "echo ${scm_prompt}")${scm}|${color}"
  fi
}

function __powerline_cwd_prompt {
  local pwd=${PWD//$HOME/\~}
  IFS='/' read -a pwd_list <<< "${pwd}"
  list_len=${#pwd_list[@]}

  if [[ $list_len -le 1 ]]; then
    cwd=$pwd
  else
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
  LEFT_PROMPT+="${separator}$(set_color ${POWERLINE_TEXT_COLOR} ${params[1]}) ${params[0]} ${normal}"
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
    if [[ ${POWERLINE_RIGHT_PROMPT} == *"date"* ]]; then
      clock="$(date +"${THEME_CLOCK_FORMAT}")$([[ $(echo "${POWERLINE_RIGHT_PROMPT}" | wc -w) -gt 1 ]] && echo " ")"
      RIGHT_PROMPT+="$(set_color ${CLOCK_THEME_PROMPT_COLOR} -)${clock}${normal}"
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

  PS1="${LEFT_PROMPT}${RIGHT_PROMPT}\n${PROMPT_CHAR} "

  ## cleanup ##
  unset LAST_SEGMENT_COLOR \
        LEFT_PROMPT RIGHT_PROMPT RIGHT_PROMPT_LENGTH \
        SEGMENTS_AT_LEFT SEGMENTS_AT_RIGHT
}
