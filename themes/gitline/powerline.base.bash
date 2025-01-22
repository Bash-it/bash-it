# shellcheck shell=bash
# shellcheck disable=SC2034 # Expected behavior for themes.

#To set color for foreground and background
function set_color() {
	local fg='' bg=''
	if [[ "${1:-}" != "-" ]]; then
		fg="38;5;${1}"
	fi
	if [[ "${2:-}" != "-" ]]; then
		bg="48;5;${2}"
		[[ -n "${fg}" ]] && bg=";${bg}"
	fi
	echo -e "\[\033[${fg}${bg}m\]"
}

#Customising User Info Segment
function __powerline_user_info_prompt() {
	local user_info="${SHORT_USER:-${USER}}"
	local color=${USER_INFO_THEME_PROMPT_COLOR-${POWERLINE_USER_INFO_COLOR-"32"}}
	local -i fg_color=15

	if [[ "${THEME_CHECK_SUDO:-false}" == true ]]; then
		if sudo -vn 2> /dev/null; then
			color=${USER_INFO_THEME_PROMPT_COLOR_SUDO-${POWERLINE_USER_INFO_COLOR_SUDO-"202"}}
		fi
	fi

	case "${POWERLINE_PROMPT_USER_INFO_MODE:-}" in
		"sudo")
			if [[ "${color}" == "${USER_INFO_THEME_PROMPT_COLOR_SUDO?}" ]]; then
				user_info="👑 ${USER}"
				fg_color=227
			fi
			;;
		*)
			if [[ -n "${SSH_CLIENT:-}" ]] || [[ -n "${SSH_CONNECTION:-}" ]]; then
				user_info="${USER_INFO_SSH_CHAR-${POWERLINE_USER_INFO_SSH_CHAR-"⌁ "}}${user_info}"
			fi
			;;
	esac
	echo "${user_info}|${color}|${fg_color}"
}

function __powerline_terraform_prompt() {
	local terraform_workspace=""

	if [[ -d .terraform ]]; then
		terraform_workspace="$(terraform_workspace_prompt)"
		[[ -n "${terraform_workspace}" ]] && echo "${TERRAFORM_CHAR-${POWERLINE_TERRAFORM_CHAR-"❲t❳ "}}${terraform_workspace}|${TERRAFORM_THEME_PROMPT_COLOR-${POWERLINE_TERRAFORM_COLOR-"161"}}"
	fi
}

function __powerline_gcloud_prompt() {
	local active_gcloud_account=""

	active_gcloud_account="$(active_gcloud_account_prompt)"
	[[ -n "${active_gcloud_account}" ]] && echo "${GCLOUD_CHAR-${POWERLINE_GCLOUD_CHAR-"❲G❳ "}}${active_gcloud_account}|${GCLOUD_THEME_PROMPT_COLOR-${POWERLINE_GCLOUD_COLOR-"161"}}"
}

function __powerline_node_prompt() {
	local node_version=""

	node_version="$(node_version_prompt)"
	[[ -n "${node_version}" ]] && echo "${NODE_CHAR-${POWERLINE_NODE_CHAR-="❲n❳ "}}${node_version}|${NODE_THEME_PROMPT_COLOR-${POWERLINE_NODE_COLOR-"22"}}"
}

#Customising Ruby Prompt
function __powerline_ruby_prompt() {
	local ruby_version
	local -i fg_color=206

	if _command_exists rvm; then
		ruby_version="$(rvm_version_prompt)"
	elif _command_exists rbenv; then
		ruby_version=$(rbenv_version_prompt)
	fi

	if [[ -n "${ruby_version:-}" ]]; then
		echo "${RUBY_CHAR?}${ruby_version}|${RUBY_THEME_PROMPT_COLOR?}|${fg_color}"
	fi
}

function __powerline_k8s_context_prompt() {
	local kubernetes_context=""

	if _command_exists kubectl; then
		kubernetes_context="$(k8s_context_prompt)"
	fi

	[[ -n "${kubernetes_context}" ]] && echo "${KUBERNETES_CONTEXT_THEME_CHAR-${POWERLINE_KUBERNETES_CONTEXT_CHAR-"⎈ "}}${kubernetes_context}|${KUBERNETES_CONTEXT_THEME_PROMPT_COLOR-${POWERLINE_KUBERNETES_CONTEXT_COLOR-"26"}}"
}

function __powerline_k8s_namespace_prompt() {
	local kubernetes_namespace=""

	if _command_exists kubectl; then
		kubernetes_namespace="$(k8s_namespace_prompt)"
	fi

	[[ -n "${kubernetes_namespace}" ]] && echo "${KUBERNETES_NAMESPACE_THEME_CHAR-${POWERLINE_KUBERNETES_NAMESPACE_CHAR-"⎈ "}}${kubernetes_namespace}|${KUBERNETES_NAMESPACE_THEME_PROMPT_COLOR-${POWERLINE_KUBERNETES_NAMESPACE_COLOR-"60"}}"
}

#Customising Python (venv) Prompt
function __powerline_python_venv_prompt() {
	local python_venv=""
	local -i fg_color=206

	if [[ -n "${CONDA_DEFAULT_ENV:-}" ]]; then
		python_venv="${CONDA_DEFAULT_ENV}"
		local PYTHON_VENV_CHAR=${CONDA_PYTHON_VENV_CHAR-${POWERLINE_CONDA_PYTHON_VENV_CHAR-"ⓔ "}}
	elif [[ -n "${VIRTUAL_ENV:-}" ]]; then
		python_venv="${VIRTUAL_ENV##*/}"
	fi

	[[ -n "${python_venv}" ]] && echo "${PYTHON_VENV_CHAR?}${python_venv}|${PYTHON_VENV_THEME_PROMPT_COLOR?}|${fg_color}"
}

#Customising SCM(GIT) Prompt
function __powerline_scm_prompt() {
	local color=""
	local scm_prompt=""
	local -i fg_color=206

	scm_prompt_vars

	if [[ "${SCM_NONE_CHAR?}" != "${SCM_CHAR?}" ]]; then
		if [[ "${SCM_DIRTY?}" -eq 3 ]]; then
			color=${SCM_THEME_PROMPT_STAGED_COLOR-${POWERLINE_SCM_STAGED_COLOR-"30"}}
			fg_color=124
		elif [[ "${SCM_DIRTY?}" -eq 2 ]]; then
			color=${SCM_THEME_PROMPT_UNSTAGED_COLOR-${POWERLINE_SCM_UNSTAGED_COLOR-"92"}}
			fg_color=56
		elif [[ "${SCM_DIRTY?}" -eq 1 ]]; then
			color=${SCM_THEME_PROMPT_DIRTY_COLOR-${POWERLINE_SCM_DIRTY_COLOR-"88"}}
			fg_color=118
		elif [[ "${SCM_DIRTY?}" -eq 0 ]]; then
			color=${SCM_THEME_PROMPT_CLEAN_COLOR-${POWERLINE_SCM_CLEAN_COLOR-"25"}}
			fg_color=16
		else
			color=${SCM_THEME_PROMPT_COLOR-${POWERLINE_SCM_CLEAN_COLOR-"25"}}
			fg_color=255
		fi
		if [[ "${SCM_GIT_CHAR?}" == "${SCM_CHAR?}" ]]; then
			scm_prompt+="${SCM_CHAR}${SCM_BRANCH?}${SCM_STATE?}"
		elif [[ "${SCM_P4_CHAR?}" == "${SCM_CHAR}" ]]; then
			scm_prompt+="${SCM_CHAR}${SCM_BRANCH?}${SCM_STATE?}"
		elif [[ "${SCM_HG_CHAR?}" == "${SCM_CHAR}" ]]; then
			scm_prompt+="${SCM_CHAR}${SCM_BRANCH?}${SCM_STATE?}"
		elif [[ "${SCM_SVN_CHAR?}" == "${SCM_CHAR}" ]]; then
			scm_prompt+="${SCM_CHAR}${SCM_BRANCH?}${SCM_STATE?}"
		fi
		echo "${scm_prompt?}|${color}|${fg_color}"
	fi
}

function __powerline_cwd_prompt() {
	local -i fg_color=16

	echo "\w|${CWD_THEME_PROMPT_COLOR?}|${fg_color}"
}

function __powerline_hostname_prompt() {
	local -i fg_color=206

	echo "\h|${HOST_THEME_PROMPT_COLOR?}|${fg_color}"
}

function __powerline_wd_prompt() {
	local -i fg_color=206

	echo "\W|${CWD_THEME_PROMPT_COLOR?}|${fg_color}"
}

function __powerline_clock_prompt() {
	local -i fg_color=206

	echo "\D{${THEME_CLOCK_FORMAT?}}|${CLOCK_THEME_PROMPT_COLOR?}|${fg_color}"
}

function __powerline_battery_prompt() {
	local color="" battery_status
	battery_status="$(battery_percentage 2> /dev/null)"
	local -i fg_color=255

	if [[ -z "${battery_status}" || "${battery_status}" == "-1" || "${battery_status}" == "no" ]]; then
		true
	else
		if [[ "$((10#${battery_status}))" -le 5 ]]; then
			color="${BATTERY_STATUS_THEME_PROMPT_CRITICAL_COLOR-"160"}"
		elif [[ "$((10#${battery_status}))" -le 25 ]]; then
			color="${BATTERY_STATUS_THEME_PROMPT_LOW_COLOR-"208"}"
		else
			color="${BATTERY_STATUS_THEME_PROMPT_GOOD_COLOR-"70"}"
		fi
		ac_adapter_connected && battery_status="${BATTERY_AC_CHAR?}${battery_status}"
		echo "${battery_status}%|${color}|${fg_color}"
	fi
}

function __powerline_in_vim_prompt() {
	local -i fg_color=206

	if [[ -n "${VIMRUNTIME:-}" ]]; then
		echo "${IN_VIM_THEME_PROMPT_TEXT?}|${IN_VIM_THEME_PROMPT_COLOR?}|${fg_color}"
	fi
}

function __powerline_aws_profile_prompt() {
	local -i fg_color=206

	if [[ -n "${AWS_PROFILE:-}" ]]; then
		echo "${AWS_PROFILE_CHAR?}${AWS_PROFILE?}|${AWS_PROFILE_PROMPT_COLOR?}|${fg_color}"
	fi
}

function __powerline_in_toolbox_prompt() {
	local -i fg_color=206

	if [[ -f /run/.containerenv ]] && [[ -f /run/.toolboxenv ]]; then
		echo "${IN_TOOLBOX_THEME_PROMPT_TEXT?}|${IN_TOOLBOX_THEME_PROMPT_COLOR?}|${fg_color}"
	fi
}

function __powerline_shlvl_prompt() {
	if [[ "${SHLVL}" -gt 1 ]]; then
		local prompt="${SHLVL_THEME_PROMPT_CHAR-"§"}"
		local level=$((SHLVL - 1))
		echo "${prompt}${level}|${SHLVL_THEME_PROMPT_COLOR-${HOST_THEME_PROMPT_COLOR-"0"}}"
	fi
}

function __powerline_dirstack_prompt() {
	if [[ "${#DIRSTACK[@]}" -gt 1 ]]; then
		local depth=$((${#DIRSTACK[@]} - 1))
		local prompt="${DIRSTACK_THEME_PROMPT_CHAR-${POWERLINE_DIRSTACK_CHAR-"←"}}"
		if [[ "${depth}" -ge 2 ]]; then
			prompt+="${depth}"
		fi
		echo "${prompt}|${DIRSTACK_THEME_PROMPT_COLOR-${POWERLINE_DIRSTACK_COLOR-${CWD_THEME_PROMPT_COLOR-${POWERLINE_CWD_COLOR-"240"}}}}"
	fi
}

function __powerline_history_number_prompt() {
	echo "${HISTORY_NUMBER_THEME_PROMPT_CHAR-${POWERLINE_HISTORY_NUMBER_CHAR-"#"}}\!|${HISTORY_NUMBER_THEME_PROMPT_COLOR-${POWERLINE_HISTORY_NUMBER_COLOR-"0"}}"
}

function __powerline_command_number_prompt() {
	echo "${COMMAND_NUMBER_THEME_PROMPT_CHAR-${POWERLINE_COMMAND_NUMBER_CHAR-"#"}}\#|${COMMAND_NUMBER_THEME_PROMPT_COLOR-${POWERLINE_COMMAND_NUMBER_COLOR-"0"}}"
}

function __powerline_duration_prompt() {
	local duration
	duration=$(_command_duration)
	[[ -n "$duration" ]] && echo "${duration}|${COMMAND_DURATION_PROMPT_COLOR?}"
}

function __powerline_left_segment() {
	local -a params
	IFS="|" read -ra params <<< "${1}"
	local pad_before_segment=" "
	local -i fg_color=206

	#for seperator character
	if [[ "${SEGMENTS_AT_LEFT?}" -eq 0 ]]; then
		if [[ "${POWERLINE_COMPACT_BEFORE_FIRST_SEGMENT:-0}" -ne 0 ]]; then
			pad_before_segment=""
		fi
	else
		if [[ "${POWERLINE_COMPACT_AFTER_SEPARATOR:-0}" -ne 0 ]]; then
			pad_before_segment=""
		fi
		# Since the previous segment wasn't the last segment, add padding, if needed
		#
		if [[ "${POWERLINE_COMPACT_BEFORE_SEPARATOR:-0}" -eq 0 ]]; then
			LEFT_PROMPT+="$(set_color - "${LAST_SEGMENT_COLOR?}") ${normal?}"
		fi
		if [[ "${LAST_SEGMENT_COLOR?}" -eq "${params[1]:-}" ]]; then
			LEFT_PROMPT+="$(set_color - "${LAST_SEGMENT_COLOR?}")${POWERLINE_LEFT_SEPARATOR_SOFT:- }${normal?}"
		else
			LEFT_PROMPT+="$(set_color "${LAST_SEGMENT_COLOR?}" "${params[1]:-}")${POWERLINE_LEFT_SEPARATOR:- }${normal?}"
		fi
	fi

	#change here to cahnge fg color
	LEFT_PROMPT+="$(set_color "${params[2]:-}" "${params[1]:-}")${pad_before_segment}${params[0]}${normal?}"
	#seperator char color == current bg
	LAST_SEGMENT_COLOR="${params[1]:-}"
	((SEGMENTS_AT_LEFT += 1))
}

function __powerline_left_last_segment_padding() {
	LEFT_PROMPT+="$(set_color - "${LAST_SEGMENT_COLOR?}") ${normal?}"
}

function __powerline_last_status_prompt() {
	[[ "$1" -ne 0 ]] && echo "${1}|${LAST_STATUS_THEME_PROMPT_COLOR-"52"}"
}

function __powerline_prompt_command() {
	local last_status="$?" ## always the first
	local info prompt_color

	local LEFT_PROMPT=""
	local SEGMENTS_AT_LEFT=0
	local LAST_SEGMENT_COLOR=""

	_save-and-reload-history "${HISTORY_AUTOSAVE:-0}"

	if [[ -n "${POWERLINE_PROMPT_DISTRO_LOGO:-}" ]]; then
		LEFT_PROMPT+="$(set_color "${PROMPT_DISTRO_LOGO_COLOR?}" "${PROMPT_DISTRO_LOGO_COLORBG?}")${PROMPT_DISTRO_LOGO?}$(set_color - -)"
	fi

	## left prompt ##
	for segment in ${POWERLINE_PROMPT-"user_info" "scm" "python_venv" "ruby" "node" "cwd"}; do
		info="$("__powerline_${segment}_prompt")"
		[[ -n "${info}" ]] && __powerline_left_segment "${info}"
	done

	[[ "${last_status}" -ne 0 ]] && __powerline_left_segment "$(__powerline_last_status_prompt "${last_status}")"

	if [[ -n "${LEFT_PROMPT:-}" ]] && [[ "${POWERLINE_COMPACT_AFTER_LAST_SEGMENT:-0}" -eq 0 ]]; then
		__powerline_left_last_segment_padding
	fi

	# By default we try to match the prompt to the adjacent segment's background color,
	# but when part of the prompt exists within that segment, we instead match the foreground color.
	prompt_color="$(set_color "${LAST_SEGMENT_COLOR?}" -)"
	if [[ -n "${LEFT_PROMPT:-}" ]] && [[ -n "${POWERLINE_LEFT_LAST_SEGMENT_PROMPT_CHAR:-}" ]]; then
		LEFT_PROMPT+="$(set_color - "${LAST_SEGMENT_COLOR?}")${POWERLINE_LEFT_LAST_SEGMENT_PROMPT_CHAR}"
		prompt_color="${normal?}"
	fi
	[[ -n "${LEFT_PROMPT:-}" ]] && LEFT_PROMPT+="${prompt_color}${POWERLINE_PROMPT_CHAR-\\$}${normal?}"

	if [[ "${POWERLINE_COMPACT_PROMPT:-0}" -eq 0 ]]; then
		LEFT_PROMPT+=" "
	fi

	PS1="${LEFT_PROMPT?}"

	## cleanup ##
	unset LAST_SEGMENT_COLOR \
		LEFT_PROMPT \
		SEGMENTS_AT_LEFT
}
