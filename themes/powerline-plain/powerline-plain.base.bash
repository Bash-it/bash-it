. "$BASH_IT/themes/powerline/powerline.base.bash"

function __powerline_left_segment {
  local OLD_IFS="${IFS}"; IFS="|"
  local params=( $1 )
  IFS="${OLD_IFS}"

  LEFT_PROMPT+="${separator}$(set_color - ${params[1]}) ${params[0]} ${normal}"
  LAST_SEGMENT_COLOR=${params[1]}
}

function __powerline_prompt_command {
  local last_status="$?" ## always the first

  LEFT_PROMPT=""

  ## left prompt ##
  for segment in $POWERLINE_PROMPT; do
    local info="$(__powerline_${segment}_prompt)"
    [[ -n "${info}" ]] && __powerline_left_segment "${info}"
  done
  [[ "${last_status}" -ne 0 ]] && __powerline_left_segment $(__powerline_last_status_prompt ${last_status})
  [[ -n "${LEFT_PROMPT}" ]] && LEFT_PROMPT+="$(set_color ${LAST_SEGMENT_COLOR} -) ${normal}"

  PS1="${LEFT_PROMPT} "

  ## cleanup ##
  unset LEFT_PROMPT
}
