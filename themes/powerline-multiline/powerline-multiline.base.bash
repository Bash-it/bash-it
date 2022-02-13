# shellcheck shell=bash
# shellcheck disable=SC2034 # Expected behavior for themes.
# shellcheck source-path=SCRIPTDIR/../powerline
source "${BASH_IT?}/themes/powerline/powerline.base.bash"

function __powerline_right_segment() {
	local -a params
	IFS="|" read -ra params <<< "${1}"
	local pad_before_segment=" "
	local padding=0

	if [[ "${SEGMENTS_AT_RIGHT}" -eq 0 ]]; then
		if [[ "${POWERLINE_COMPACT_AFTER_LAST_SEGMENT:-${POWERLINE_COMPACT:-0}}" -ne 0 ]]; then
			pad_before_segment=""
		fi
		RIGHT_PROMPT+="$(set_color "${params[1]:-}" -)${POWERLINE_RIGHT_LAST_SEGMENT_END_CHAR:-}${normal?}"
		((padding += 1))
	else
		if [[ "${POWERLINE_COMPACT_BEFORE_SEPARATOR:-}" -ne 0 ]]; then
			pad_before_segment=""
		fi
		# Since the previous segment wasn't the last segment, add padding, if needed
		#
		if [[ "${POWERLINE_COMPACT_AFTER_SEPARATOR:-0}" -eq 0 ]]; then
			RIGHT_PROMPT+="$(set_color - "${LAST_SEGMENT_COLOR?}") ${normal}"
			((padding += 1))
		fi
		if [[ "${LAST_SEGMENT_COLOR}" -eq "${params[1]:-}" ]]; then
			RIGHT_PROMPT+="$(set_color - "${LAST_SEGMENT_COLOR?}")${POWERLINE_RIGHT_SEPARATOR_SOFT- }${normal?}"
		else
			RIGHT_PROMPT+="$(set_color "${params[1]:-}" "${LAST_SEGMENT_COLOR?}")${POWERLINE_RIGHT_SEPARATOR- }${normal?}"
		fi
		((padding += 1))
	fi

	RIGHT_PROMPT+="$(set_color - "${params[1]:-}")${pad_before_segment}${params[0]}${normal?}"

	((padding += ${#pad_before_segment}))
	((padding += ${#params[0]}))

	((RIGHT_PROMPT_LENGTH += padding))
	LAST_SEGMENT_COLOR="${params[1]:-}"
	((SEGMENTS_AT_RIGHT += 1))
}

function __powerline_right_first_segment_padding() {
	RIGHT_PROMPT+="$(set_color - "${LAST_SEGMENT_COLOR?}") ${normal?}"
	((RIGHT_PROMPT_LENGTH += 1))
}

function __powerline_last_status_prompt() {
	if [[ "${1?}" -ne 0 ]]; then
		printf '%b %s %b' "$(set_color "${LAST_STATUS_THEME_PROMPT_COLOR-"52"}" -)" "${1}" "${normal?}"
	fi
}

function __powerline_prompt_command() {
	local last_status="$?" ## always the first
	local beginning_of_line='\[\e[G\]'
	local move_cursor_rightmost='\e[500C'
	local info prompt_color segment prompt

	local LEFT_PROMPT=""
	local RIGHT_PROMPT=""
	local RIGHT_PROMPT_LENGTH=${POWERLINE_PADDING:-2}
	local SEGMENTS_AT_LEFT=0
	local SEGMENTS_AT_RIGHT=0
	local LAST_SEGMENT_COLOR=""

	_save-and-reload-history "${HISTORY_AUTOSAVE:-0}"

	if [[ -n "${POWERLINE_PROMPT_DISTRO_LOGO:-}" ]]; then
		LEFT_PROMPT+="$(set_color "${PROMPT_DISTRO_LOGO_COLOR?}" "${PROMPT_DISTRO_LOGO_COLORBG?}")${PROMPT_DISTRO_LOGO?}$(set_color - -)"
	fi

	## left prompt ##
	# shellcheck disable=SC2068 # intended behavior
	for segment in ${POWERLINE_PROMPT[@]-"user_info" "scm" "python_venv" "ruby" "node" "cwd"}; do
		info="$("__powerline_${segment}_prompt")"
		if [[ -n "${info}" ]]; then
			__powerline_left_segment "${info}"
		fi
	done

	if [[ -n "${LEFT_PROMPT:-}" && "${POWERLINE_COMPACT_AFTER_LAST_SEGMENT:-${POWERLINE_COMPACT:-0}}" -eq 0 ]]; then
		__powerline_left_last_segment_padding
	fi

	# By default we try to match the prompt to the adjacent segment's background color,
	# but when part of the prompt exists within that segment, we instead match the foreground color.
	prompt_color="$(set_color "${LAST_SEGMENT_COLOR?}" -)"
	if [[ -n "${LEFT_PROMPT:-}" && -n "${POWERLINE_LEFT_LAST_SEGMENT_END_CHAR:-}" ]]; then
		LEFT_PROMPT+="$(set_color - "${LAST_SEGMENT_COLOR?}")${POWERLINE_LEFT_LAST_SEGMENT_END_CHAR}"
		prompt_color="${normal?}"
	fi

	## right prompt ##
	if [[ -n "${POWERLINE_RIGHT_PROMPT[*]:-}" ]]; then
		# LEFT_PROMPT+="${move_cursor_rightmost}"
		# shellcheck disable=SC2068 # intended behavior
		for segment in ${POWERLINE_RIGHT_PROMPT[@]}; do
			info="$("__powerline_${segment}_prompt")"
			[[ -n "${info}" ]] && __powerline_right_segment "${info}"
		done

		if [[ -n "${RIGHT_PROMPT:-}" && "${POWERLINE_COMPACT_BEFORE_FIRST_SEGMENT:-${POWERLINE_COMPACT:-0}}" -eq 0 ]]; then
			__powerline_right_first_segment_padding
		fi

		RIGHT_PAD=$(printf "%.s " $(seq 1 "${RIGHT_PROMPT_LENGTH}"))
		LEFT_PROMPT+="${RIGHT_PAD}${move_cursor_rightmost}"
		LEFT_PROMPT+="\033[$((${#RIGHT_PAD} - 1))D"
	fi

	prompt="${prompt_color}${PROMPT_CHAR-${POWERLINE_PROMPT_CHAR-\\$}}${normal?}"
	if [[ "${POWERLINE_COMPACT_PROMPT:-${POWERLINE_COMPACT:-0}}" -eq 0 ]]; then
		prompt+=" "
	fi

	PS1="${beginning_of_line}${normal?}${LEFT_PROMPT}${RIGHT_PROMPT}\n$(__powerline_last_status_prompt "${last_status}")${prompt}"
}
