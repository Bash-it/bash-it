# shellcheck shell=bash
# shellcheck disable=SC2034 # Expected behavior for themes.

SCM_THEME_PROMPT_PREFIX="  "
SCM_THEME_PROMPT_SUFFIX=" "
SCM_THEME_PROMPT_DIRTY=" ?"
SCM_THEME_PROMPT_CLEAN=" ✓"

function distro_prompt_info() {
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

function nodejs_prompt_info() {
	if [[ -n $(command -v node) && -d "node_modules" ]]; then
		echo "  $(node -v) "
	fi
}

function python_prompt_info() {
	if [[ -n "$VIRTUAL_ENV" ]]; then
		echo "  ${VIRTUAL_ENV##*/} "
	fi
}

function rust_prompt_info() {
	if [[ -n $(command -v rustc) && -f "Cargo.toml" ]]; then
		echo "  $(rustc --version | awk '{print $2}') "
	fi
}

# Static prompt info
distro_prompt_info=" $(distro_prompt_info) "

# Colors
dir_color="\[\033[38;2;227;229;229m\]\[\033[48;2;118;159;240m\]"
distro_color="\[\033[48;2;163;174;210m\]\[\033[38;2;9;12;12m\]"
scm_color="\[\033[38;2;118;159;240m\]\[\033[48;2;57;66;96m\]"
clock_color="\[\033[38;2;160;169;203m\]\[\033[48;2;29;34;48m\]"
other_color="\[\033[38;2;57;66;96m\]\[\033[48;2;33;39;54m\]"

# Separators
sep1="\[\033[38;2;163;174;210m\]░▒▓"
sep2="\[\033[48;2;118;159;240m\]\[\033[38;2;163;174;210m\]"
sep3="\[\033[38;2;118;159;240m\]\[\033[48;2;57;66;96m\]"
sep4="\[\033[38;2;57;66;96m\]\[\033[48;2;33;39;54m\]"
sep5="\[\033[38;2;33;39;54m\]\[\033[48;2;29;34;48m\]"
sep6="\[\033[38;2;29;34;48m\]\[\033[49m\] "

function prompt_command() {
	if [[ "$?" -eq 0 ]]; then
		cursor_color="${bold_green?}"
	else
		cursor_color="${bold_red?}"
	fi

	if [[ "${USER:-${LOGNAME?}}" = root ]]; then
		character="▶"
	else
		character="❯"
	fi

	# Dynamic prompt info
	scm_prompt_info="$(scm_prompt_info)"
	nodejs_prompt_info="$(nodejs_prompt_info)"
	python_prompt_info="$(python_prompt_info)"
	rust_prompt_info="$(rust_prompt_info)"

	PS1="\n${sep1}${distro_color}${distro_prompt_info}${sep2}${dir_color} \w ${sep3}${scm_color}${scm_prompt_info}${sep4}${other_color}${nodejs_prompt_info}${python_prompt_info}${rust_prompt_info}${sep5}${clock_color}   \A ${sep6}\n${cursor_color}${character} ${normal?}"
}

safe_append_prompt_command prompt_command
