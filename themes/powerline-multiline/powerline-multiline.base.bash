. "$BASH_IT/themes/powerline/powerline.base.bash"

function __powerline_last_status_prompt {
  [[ "$1" -ne 0 ]] && echo "$(set_color ${LAST_STATUS_THEME_PROMPT_COLOR} -) ${1} ${normal}"
}

function __powerline_right_segment {
  local OLD_IFS="${IFS}"; IFS="|"
  local params=( $1 )
  IFS="${OLD_IFS}"
  local padding=0
  local pad_before_segment=" "

  if [[ "${SEGMENTS_AT_RIGHT}" -eq 0 ]]; then
    if [[ "${POWERLINE_COMPACT_AFTER_LAST_SEGMENT}" -ne 0 ]]; then
      pad_before_segment=""
    fi
    RIGHT_PROMPT+="$(set_color ${params[1]} -)${POWERLINE_RIGHT_END}${normal}"
    (( padding += 1 ))
  else
    if [[ "${POWERLINE_COMPACT_BEFORE_SEPARATOR}" -ne 0 ]]; then
      pad_before_segment=""
    fi
    # Since the previous segment wasn't the last segment, add padding, if needed
    #
    if [[ "${POWERLINE_COMPACT_AFTER_SEPARATOR}" -eq 0 ]]; then
      RIGHT_PROMPT+="$(set_color - ${LAST_SEGMENT_COLOR}) ${normal}"
      (( padding += 1 ))
    fi
    if [[ "${LAST_SEGMENT_COLOR}" -eq "${params[1]}" ]]; then
      RIGHT_PROMPT+="$(set_color - ${LAST_SEGMENT_COLOR})${POWERLINE_RIGHT_SEPARATOR_SOFT}${normal}"
    else
      RIGHT_PROMPT+="$(set_color ${params[1]} ${LAST_SEGMENT_COLOR})${POWERLINE_RIGHT_SEPARATOR}${normal}"
    fi
    (( padding += 1 ))
  fi

  RIGHT_PROMPT+="$(set_color - ${params[1]})${pad_before_segment}${params[0]}${normal}"

  (( padding += ${#pad_before_segment} ))
  (( padding += ${#params[0]} ))

  (( RIGHT_PROMPT_LENGTH += padding ))
  LAST_SEGMENT_COLOR="${params[1]}"
  (( SEGMENTS_AT_RIGHT += 1 ))
}

function __powerline_right_first_segment_padding {
  RIGHT_PROMPT+="$(set_color - ${LAST_SEGMENT_COLOR}) ${normal}"
  (( RIGHT_PROMPT_LENGTH += 1 ))
}

function __powerline_prompt_command {
  local last_status="$?" ## always the first
  local move_cursor_rightmost='\033[500C'

  LEFT_PROMPT=""
  RIGHT_PROMPT=""
  RIGHT_PROMPT_LENGTH=${POWERLINE_PADDING}
  SEGMENTS_AT_LEFT=0
  SEGMENTS_AT_RIGHT=0
  LAST_SEGMENT_COLOR=""

  ## left prompt ##
  for segment in $POWERLINE_LEFT_PROMPT; do
    local info="$(__powerline_${segment}_prompt)"
    [[ -n "${info}" ]] && __powerline_left_segment "${info}"
  done

  if [[ -n "${LEFT_PROMPT}" ]] && [[ "${POWERLINE_COMPACT_AFTER_LAST_SEGMENT}" -eq 0 ]]; then
    __powerline_left_last_segment_padding
  fi

  [[ -n "${LEFT_PROMPT}" ]] && LEFT_PROMPT+="$(set_color ${LAST_SEGMENT_COLOR} -)${POWERLINE_LEFT_END}${normal}"

  ## right prompt ##
  if [[ -n "${POWERLINE_RIGHT_PROMPT}" ]]; then
    # LEFT_PROMPT+="${move_cursor_rightmost}"
    for segment in $POWERLINE_RIGHT_PROMPT; do
      local info="$(__powerline_${segment}_prompt)"
      [[ -n "${info}" ]] && __powerline_right_segment "${info}"
    done

    if [[ -n "${RIGHT_PROMPT}" ]] && [[ "${POWERLINE_COMPACT_BEFORE_FIRST_SEGMENT}" -eq 0 ]]; then
      __powerline_right_first_segment_padding
    fi

    RIGHT_PAD=$(printf "%.s " $(seq 1 $RIGHT_PROMPT_LENGTH))
    LEFT_PROMPT+="${RIGHT_PAD}${move_cursor_rightmost}"
    LEFT_PROMPT+="\033[$(( ${#RIGHT_PAD} - 1 ))D"
  fi

  local prompt="${PROMPT_CHAR}"
  if [[ "${POWERLINE_COMPACT_PROMPT}" -eq 0 ]]; then
    prompt+=" "
  fi

  PS1="${LEFT_PROMPT}${RIGHT_PROMPT}\n$(__powerline_last_status_prompt ${last_status})${prompt}"

  ## cleanup ##
  unset LAST_SEGMENT_COLOR \
        LEFT_PROMPT RIGHT_PROMPT RIGHT_PROMPT_LENGTH \
        SEGMENTS_AT_LEFT SEGMENTS_AT_RIGHT
}
