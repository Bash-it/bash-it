# shellcheck shell=bash
# shellcheck disable=SC2034 # Expected behavior for themes.

SCM_THEME_PROMPT_PREFIX="  "
SCM_THEME_PROMPT_SUFFIX=" "
SCM_THEME_PROMPT_DIRTY=" ?"
SCM_THEME_PROMPT_CLEAN=" ✓"

function _tokyonight-distro-prompt-info() {
	local id

	if [[ -f /etc/os-release ]]; then
		id=$(
			# shellcheck disable=SC1091
			. /etc/os-release
			echo "$ID" | tr '[:upper:]' '[:lower:]'
		)
	else
		echo ""
		return
	fi

	case "$id" in
		*ubuntu*) echo "" ;;
		*debian*) echo "" ;;
		*fedora*) echo "" ;;
		*arch*) echo "" ;;
		*manjaro*) echo "" ;;
		*centos*) echo "" ;;
		*rhel*) echo "" ;;
		*alpine*) echo "" ;;
		*opensuse*) echo "" ;;
		*nixos*) echo "" ;;
		*void*) echo "" ;;
		*gentoo*) echo "" ;;
		*slackware*) echo "" ;;
		*) echo "" ;;
	esac
}

function _tokyonight-cache-nodejs-prompt-info() {
	if [[ -n "$(command -v node)" ]]; then
		echo "  $(node -v) "
	fi
}

function _tokyonight-nodejs-prompt-info() {
	if [[ -n "$_tokyonight_cached_nodejs_prompt_info" && -f package.json ]]; then
		echo "$_tokyonight_cached_nodejs_prompt_info"
	fi
}

function _tokyonight-cache-rust-prompt-info() {
	if [[ -n "$(command -v rustc)" ]]; then
		echo "  $(rustc --version | awk '{print $2}') "
	fi
}

function _tokyonight-rust-prompt-info() {
	if [[ -n "$_tokyonight_cached_rust_prompt_info" && -f Cargo.toml ]]; then
		echo "$_tokyonight_cached_rust_prompt_info"
	fi
}

function _tokyonight-python-prompt-info() {
	if [[ -n "$VIRTUAL_ENV" ]]; then
		echo "  ${VIRTUAL_ENV##*/} "
	fi
}

# Static prompt info
: "${TOKYONIGHT_DISTRO_PROMPT_INFO:="$(_tokyonight-distro-prompt-info)"}"
_tokyonight_cached_nodejs_prompt_info="$(_tokyonight-cache-nodejs-prompt-info)"
_tokyonight_cached_rust_prompt_info="$(_tokyonight-cache-rust-prompt-info)"

# Colors
_tokyonight_dir_color="\[\033[38;2;227;229;229m\]\[\033[48;2;118;159;240m\]"
_tokyonight_distro_color="\[\033[48;2;163;174;210m\]\[\033[38;2;9;12;12m\]"
_tokyonight_scm_color="\[\033[38;2;118;159;240m\]\[\033[48;2;57;66;96m\]"
_tokyonight_clock_color="\[\033[38;2;160;169;203m\]\[\033[48;2;29;34;48m\]"
_tokyonight_other_color="\[\033[38;2;57;66;96m\]\[\033[48;2;33;39;54m\]"

# Separators
_tokyonight_sep1="\[\033[38;2;163;174;210m\]░▒▓"
_tokyonight_sep2="\[\033[48;2;118;159;240m\]\[\033[38;2;163;174;210m\]"
_tokyonight_sep3="\[\033[38;2;118;159;240m\]\[\033[48;2;57;66;96m\]"
_tokyonight_sep4="\[\033[38;2;57;66;96m\]\[\033[48;2;33;39;54m\]"
_tokyonight_sep5="\[\033[38;2;33;39;54m\]\[\033[48;2;29;34;48m\]"
_tokyonight_sep6="\[\033[38;2;29;34;48m\]\[\033[49m\]"

# Characters
: "${TOKYONIGHT_USER_CHARACTER:="❯"}"
: "${TOKYONIGHT_ROOT_CHARACTER:="▶"}"

function _tokyonight-prompt-command() {
	local exit_code="$?"
	local cursor_color
	local character

	if [[ "$exit_code" -eq 0 ]]; then
		cursor_color="${bold_green?}"
	else
		cursor_color="${bold_red?}"
	fi

	if [[ "${USER:-${LOGNAME?}}" = root ]]; then
		character="$TOKYONIGHT_ROOT_CHARACTER"
	else
		character="$TOKYONIGHT_USER_CHARACTER"
	fi

	# Dynamic prompt info
	local scm_prompt_info
	local nodejs_prompt_info
	local python_prompt_info
	local rust_prompt_info

	scm_prompt_info="$(scm_prompt_info)"
	nodejs_prompt_info="$(_tokyonight-nodejs-prompt-info)"
	python_prompt_info="$(_tokyonight-python-prompt-info)"
	rust_prompt_info="$(_tokyonight-rust-prompt-info)"

	PS1="\n${_tokyonight_sep1}${_tokyonight_distro_color} ${TOKYONIGHT_DISTRO_PROMPT_INFO} ${_tokyonight_sep2}${_tokyonight_dir_color} \w ${_tokyonight_sep3}${_tokyonight_scm_color}${scm_prompt_info}${_tokyonight_sep4}${_tokyonight_other_color}${nodejs_prompt_info}${python_prompt_info}${rust_prompt_info}${_tokyonight_sep5}${_tokyonight_clock_color}   \A ${_tokyonight_sep6}\n${cursor_color}${character} ${normal?}"
}

safe_append_prompt_command _tokyonight-prompt-command
