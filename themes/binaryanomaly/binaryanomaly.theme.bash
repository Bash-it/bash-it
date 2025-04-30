# shellcheck shell=bash
# shellcheck disable=SC2034 # Expected behavior for themes.

# Detect whether a reboot is required
function show_reboot_required() {
	if [[ -n "${_bf_prompt_reboot_info:-}" ]]; then
		if [[ -f /var/run/reboot-required ]]; then
			printf '%s' "Reboot required!"
		fi
	fi
}

# Set different host color for local and remote sessions
function set_host_color() {
	# Detect if connection is through SSH
	if [[ -n "${SSH_CLIENT:-}" ]]; then
		printf '%s' "${lime_yellow?}"
	else
		printf '%s' "${light_orange?}"
	fi
}

# Set different username color for users and root
function set_user_color() {
	case ${EUID:-$UID} in
		0)
			printf '%s' "${red?}"
			;;
		*)
			printf '%s' "${cyan?}"
			;;
	esac
}

# Define custom colors we need
# non-printable bytes in PS1 need to be contained within \[ \].
# Otherwise, bash will count them in the length of the prompt
function set_custom_colors() {
	dark_grey="\[$(tput setaf 8)\]"
	light_grey="\[$(tput setaf 248)\]"

	light_orange="\[$(tput setaf 172)\]"
	bright_yellow="\[$(tput setaf 220)\]"
	lime_yellow="\[$(tput setaf 190)\]"

	powder_blue="\[$(tput setaf 153)\]"
}

function __ps_time() {
	local clock_prompt
	clock_prompt="$(clock_prompt)"
	printf '%s\n' "${clock_prompt}${normal?}"
}

function prompt_command() {
	local show_reboot_required set_user_color set_host_color scm_prompt ps_time
	show_reboot_required="$(show_reboot_required)"
	ps_reboot="${bright_yellow?}${show_reboot_required}${normal?}\n"

	set_user_color="$(set_user_color)"
	ps_username="${set_user_color}\u${normal}"
	ps_uh_separator="${dark_grey?}@${normal}"
	set_host_color="$(set_host_color)"
	ps_hostname="${set_host_color}\h${normal}"

	ps_path="${yellow?}\w${normal}"
	scm_prompt="$(scm_prompt)"
	ps_scm_prompt="${light_grey?}${scm_prompt}"

	ps_user_mark="${normal} ${normal}"
	ps_user_input="${normal}"

	# Set prompt
	ps_time="$(__ps_time)"
	PS1="$ps_reboot${ps_time}$ps_username$ps_uh_separator$ps_hostname $ps_path $ps_scm_prompt$ps_user_mark$ps_user_input"
}

# Initialize custom colors
set_custom_colors

: "${THEME_CLOCK_COLOR:="$dark_grey"}"

# scm theming
SCM_THEME_PROMPT_PREFIX=""
SCM_THEME_PROMPT_SUFFIX=""

SCM_THEME_PROMPT_DIRTY=" ${bold_red?}✗${light_grey?}"
SCM_THEME_PROMPT_CLEAN=" ${green?}✓${light_grey?}"
SCM_GIT_CHAR="${green?}±${light_grey?}"
SCM_SVN_CHAR="${bold_cyan?}⑆${light_grey?}"
SCM_HG_CHAR="${bold_red?}☿${light_grey?}"

safe_append_prompt_command prompt_command
