# shellcheck shell=bats
# shellcheck disable=SC2034 # Variables consumed by externally-loaded powerline functions.

load "${MAIN_BASH_IT_DIR?}/test/test_helper.bash"

function local_setup_file() {
	setup_libs "colors"
	load "${BASH_IT?}/themes/powerline-multiline/powerline-multiline.base.bash"
}

function local_setup() {
	unset THEME_CLOCK_FORMAT THEME_CHECK_SUDO SSH_CLIENT SSH_CONNECTION
}

function right_prompt_length() {
	local RIGHT_PROMPT="" RIGHT_PROMPT_LENGTH=0 SEGMENTS_AT_RIGHT=0 LAST_SEGMENT_COLOR="" segment
	for segment in "$@"; do
		__powerline_right_segment "${segment}"
	done
	printf '%s' "${RIGHT_PROMPT_LENGTH}"
}

@test "powerline-multiline base: the default clock and user_info segments are measured at their rendered width" {
	# The right prompt is right-aligned by the measured length. Counting the literal
	# \D{%H:%M:%S} (12 chars for an 8-char clock) or \u (2 chars for the username)
	# leaves a gap at the right edge or wraps the prompt onto the next line.
	local escaped rendered
	escaped="$(right_prompt_length "$(__powerline_clock_prompt)" "$(__powerline_user_info_prompt)")"
	rendered="$(right_prompt_length "12:34:56|240" "$(id -un)|32")"
	assert_equal "${escaped}" "${rendered}"
}

@test "powerline-multiline base: the bash < 4.4 escape fallback renders like bash's own prompt expansion" {
	if [[ "${BASH_VERSINFO[0]}" -lt 4 || ("${BASH_VERSINFO[0]}" -eq 4 && "${BASH_VERSINFO[1]}" -lt 4) ]]; then
		skip "needs \${text@P} (bash 4.4+) as the reference"
	fi
	local HOME="${BATS_TEST_TMPDIR?}" dir text expected
	mkdir -p "${HOME}/sub"
	for dir in "${HOME}" "${HOME}/sub" /; do
		cd "${dir}" || return
		text='\u@\h \w \W \D{%Y}'
		expected="${text@P}"
		__powerline_expand_prompt_escapes
		assert_equal "${text}" "${expected}"
	done
}
