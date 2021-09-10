# shellcheck shell=bash
. "$BASH_IT/themes/powerline/powerline.base.bash"

case $HISTCONTROL in
*'auto'*)
	: # Do nothing, already configured.
	;;
*)
	# Append new history lines to history file
	HISTCONTROL="${HISTCONTROL:-}${HISTCONTROL:+:}autosave"
	;;
esac
safe_append_preexec '_bash-it-history-auto-load'
safe_append_prompt_command '_bash-it-history-auto-save'

function __powerline_left_segment {
  local OLD_IFS="${IFS}"; IFS="|"
  local params=( $1 )
  IFS="${OLD_IFS}"
  local pad_before_segment=" "

  if [[ "${SEGMENTS_AT_LEFT}" -eq 0 ]]; then
    if [[ "${POWERLINE_COMPACT_BEFORE_FIRST_SEGMENT}" -ne 0 ]]; then
      pad_before_segment=""
    fi
  else
    if [[ "${POWERLINE_COMPACT_AFTER_SEPARATOR}" -ne 0 ]]; then
      pad_before_segment=""
    fi
    # Since the previous segment wasn't the last segment, add padding, if needed
    #
    if [[ "${POWERLINE_COMPACT_BEFORE_SEPARATOR}" -eq 0 ]]; then
      LEFT_PROMPT+="$(set_color - ${LAST_SEGMENT_COLOR}) ${normal}"
    fi
  fi

  LEFT_PROMPT+="$(set_color - ${params[1]})${pad_before_segment}${params[0]}${normal}"
  LAST_SEGMENT_COLOR=${params[1]}
  (( SEGMENTS_AT_LEFT += 1 ))
}

function __powerline_prompt_command {
  local last_status="$?" ## always the first

  LEFT_PROMPT=""
  SEGMENTS_AT_LEFT=0
  LAST_SEGMENT_COLOR=""
  PROMPT_AFTER="${POWERLINE_PROMPT_AFTER}"

  ## left prompt ##
  for segment in $POWERLINE_PROMPT; do
    local info="$(__powerline_${segment}_prompt)"
    [[ -n "${info}" ]] && __powerline_left_segment "${info}"
  done

  [[ "${last_status}" -ne 0 ]] && __powerline_left_segment $(__powerline_last_status_prompt ${last_status})

  if [[ -n "${LEFT_PROMPT}" ]] && [[ "${POWERLINE_COMPACT_AFTER_LAST_SEGMENT}" -eq 0 ]]; then
    __powerline_left_last_segment_padding
  fi

  if [[ "${POWERLINE_COMPACT_PROMPT}" -eq 0 ]]; then
    LEFT_PROMPT+=" "
  fi

  PS1="${LEFT_PROMPT}${PROMPT_AFTER}"

  ## cleanup ##
  unset LAST_SEGMENT_COLOR \
        LEFT_PROMPT \
        SEGMENTS_AT_LEFT
}
