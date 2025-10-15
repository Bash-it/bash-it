# shellcheck shell=bash
cite about-plugin
about-plugin 'automatically set your xterm title with host and location info'
url "https://github.com/Bash-it/bash-it"

function _short-dirname() {
	local dir_name="${PWD/~/\~}"
	if [[ "${SHORT_TERM_LINE:-}" == true && "${#dir_name}" -gt 8 ]]; then
		echo "${dir_name##*/}"
	else
		echo "${dir_name}"
	fi
}

function _short-command() {
	local input_command="$*"
	if [[ "${SHORT_TERM_LINE:-}" == true && "${#input_command}" -gt 8 ]]; then
		echo "${input_command%% *}"
	else
		echo "${input_command}"
	fi
}

function set_xterm_title() {
	local title="${1:-}"
	echo -ne "\033]0;${title}\007"
}

function precmd_xterm_title() {
	set_xterm_title "${SHORT_USER:-${USER}}@${SHORT_HOSTNAME:-${HOSTNAME}} $(_short-dirname) ${PROMPT_CHAR:-\$}"
}

function preexec_xterm_title() {
	local command_line="${BASH_COMMAND:-${1:-}}"
	local directory_name short_command
	directory_name="$(_short-dirname)"
	short_command="$(_short-command "${command_line}")"
	set_xterm_title "${short_command} {${directory_name}} (${SHORT_USER:-${USER}}@${SHORT_HOSTNAME:-${HOSTNAME}})"
}

case "${TERM:-dumb}" in
	xterm* | rxvt* | gnome-terminal | konsole | zvt | dtterm | kterm | Eterm | zterm)
		# Check for safe_append functions and use fallback if not available
		if _is_function safe_append_prompt_command; then
			safe_append_prompt_command 'precmd_xterm_title'
		elif [[ -n "${PROMPT_COMMAND:-}" ]]; then
			# Fallback: append to PROMPT_COMMAND if it exists
			PROMPT_COMMAND="precmd_xterm_title;${PROMPT_COMMAND}"
		else
			PROMPT_COMMAND='precmd_xterm_title'
		fi

		if _is_function safe_append_preexec; then
			safe_append_preexec 'preexec_xterm_title'
		else
			# Fallback: register function directly if preexec array is available
			if [[ -n "${preexec_functions:-}" ]]; then
				preexec_functions+=('preexec_xterm_title')
			fi
		fi
		;;
esac
