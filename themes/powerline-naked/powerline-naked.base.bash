# shellcheck shell=bash
# shellcheck disable=SC2034,SC1091 # Expected behavior for themes.
source "${BASH_IT?}/themes/powerline/powerline.base.bash"

function __powerline_left_segment {
	local OLD_IFS="${IFS}" params=()
	# shellcheck disable=SC2206 # not needed because we are splitting on "|"
	IFS="|" params=($1)
	IFS="${OLD_IFS}"
	local separator=""
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
		if [[ "${POWERLINE_COMPACT_BEFORE_SEPARATOR:-0}" -eq 0 ]]; then
			LEFT_PROMPT+=" "
		fi
		LEFT_PROMPT+="${POWERLINE_LEFT_SEPARATOR}"
	fi

	#change here to cahnge fg color
	LEFT_PROMPT+="$(set_color "${params[1]:-}" -)${pad_before_segment}${params[0]}${normal?}"
	#seperator char color == current bg
	LAST_SEGMENT_COLOR="${params[1]:-}"
	((SEGMENTS_AT_LEFT += 1))

	_save-and-reload-history "${HISTORY_AUTOSAVE:-0}"
}

function __powerline_left_last_segment_padding {
	LEFT_PROMPT+="$(set_color "${LAST_SEGMENT_COLOR?}" -) ${normal?}"
}
