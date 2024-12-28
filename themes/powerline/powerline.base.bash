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
		if [[ -n "${fg}" ]]; then
			bg=";${bg}"
		fi
	fi
	printf '\[\\e[%s%sm\]' "${fg}" "${bg}"
}

#Customising User Info Segment
function __powerline_user_info_prompt() {
	local user_info='\u'
	local color=${USER_INFO_THEME_PROMPT_COLOR-${POWERLINE_USER_INFO_COLOR-"32"}}

	if [[ "${THEME_CHECK_SUDO:-false}" == true ]]; then
		if sudo -vn 2> /dev/null; then
			color=${USER_INFO_THEME_PROMPT_COLOR_SUDO-${POWERLINE_USER_INFO_COLOR_SUDO-"202"}}
			if [[ "${POWERLINE_PROMPT_USER_INFO_MODE:-}" == "sudo" ]]; then
				user_info="!"
			fi
		fi
	fi

	if [[ -n "${SSH_CLIENT:-}" || -n "${SSH_CONNECTION:-}" ]]; then
		user_info="${USER_INFO_SSH_CHAR-${POWERLINE_USER_INFO_SSH_CHAR-"⌁"}}${user_info}"
	fi
	printf '%s|%s' "${user_info}" "${color}"
}

function __powerline_terraform_prompt() {
	local terraform_workspace=""

	if [[ -d .terraform ]]; then
		terraform_workspace="$(terraform_workspace_prompt)"
		if [[ -n "${terraform_workspace}" ]]; then
			printf '%s%s|%s' "${TERRAFORM_CHAR-${POWERLINE_TERRAFORM_CHAR-"❲t❳"}}" "${terraform_workspace}" "${TERRAFORM_THEME_PROMPT_COLOR-${POWERLINE_TERRAFORM_COLOR-"161"}}"
		fi
	fi
}

function __powerline_gcloud_prompt() {
	local active_gcloud_account=""

	active_gcloud_account="$(active_gcloud_account_prompt)"
	if [[ -n "${active_gcloud_account}" ]]; then
		printf '%s%s|%s' "${GCLOUD_CHAR-${POWERLINE_GCLOUD_CHAR-"❲G❳"}}" "${active_gcloud_account}" "${GCLOUD_THEME_PROMPT_COLOR-${POWERLINE_GCLOUD_COLOR-"161"}}"
	fi
}

function __powerline_node_prompt() {
	local node_version=""

	node_version="$(node_version_prompt)"
	if [[ -n "${node_version}" ]]; then
		printf '%s%s|%s' "${NODE_CHAR-${POWERLINE_NODE_CHAR-="❲n❳"}}" "${node_version}" "${NODE_THEME_PROMPT_COLOR-${POWERLINE_NODE_COLOR-"22"}}"
	fi
}

#Customising Ruby Prompt
function __powerline_ruby_prompt() {
	local ruby_version

	if _command_exists rvm; then
		ruby_version="$(rvm_version_prompt)"
	elif _command_exists rbenv; then
		ruby_version=$(rbenv_version_prompt)
	fi

	if [[ -n "${ruby_version:-}" ]]; then
		printf '%s%s|%s' "${RUBY_CHAR-${POWERLINE_RUBY_CHAR-"💎"}}" "${ruby_version}" "${RUBY_THEME_PROMPT_COLOR-${POWERLINE_RUBY_COLOR-"161"}}"
	fi
}

function __powerline_k8s_context_prompt() {
	local kubernetes_context=""

	if _command_exists kubectl; then
		kubernetes_context="$(k8s_context_prompt)"
	fi

	if [[ -n "${kubernetes_context}" ]]; then
		printf '%s%s|%s' "${KUBERNETES_CONTEXT_THEME_CHAR-${POWERLINE_KUBERNETES_CONTEXT_CHAR-"⎈"}}" "${kubernetes_context}" "${KUBERNETES_CONTEXT_THEME_PROMPT_COLOR-${POWERLINE_KUBERNETES_CONTEXT_COLOR-"26"}}"
	fi
}

function __powerline_k8s_namespace_prompt() {
	local kubernetes_namespace=""

	if _command_exists kubectl; then
		kubernetes_namespace="$(k8s_namespace_prompt)"
	fi

	if [[ -n "${kubernetes_namespace}" ]]; then
		printf '%s%s|%s' "${KUBERNETES_NAMESPACE_THEME_CHAR-${POWERLINE_KUBERNETES_NAMESPACE_CHAR-"⎈"}}" "${kubernetes_namespace}" "${KUBERNETES_NAMESPACE_THEME_PROMPT_COLOR-${POWERLINE_KUBERNETES_NAMESPACE_COLOR-"60"}}"
	fi
}

#Customising Python (venv) Prompt
function __powerline_python_venv_prompt() {
	local python_venv=""

	if [[ -n "${CONDA_DEFAULT_ENV:-}" ]]; then
		python_venv="${CONDA_DEFAULT_ENV}"
		local PYTHON_VENV_CHAR=${CONDA_PYTHON_VENV_CHAR-${POWERLINE_CONDA_PYTHON_VENV_CHAR-"ⓔ"}}
	elif [[ -n "${VIRTUAL_ENV:-}" ]]; then
		python_venv="${VIRTUAL_ENV##*/}"
	fi

	if [[ -n "${python_venv}" ]]; then
		printf '%s%s|%s' "${PYTHON_VENV_CHAR-${POWERLINE_PYTHON_VENV_CHAR-"ⓔ"}}" "${python_venv}" "${PYTHON_VENV_THEME_PROMPT_COLOR-${POWERLINE_PYTHON_VENV_COLOR-"35"}}"
	fi
}

#Customising SCM(GIT) Prompt
function __powerline_scm_prompt() {
	local color=""
	local scm_prompt=""

	scm_prompt_vars

	if [[ "${SCM_NONE_CHAR?}" != "${SCM_CHAR?}" ]]; then
		if [[ "${SCM_DIRTY?}" -eq 3 ]]; then
			color=${SCM_THEME_PROMPT_STAGED_COLOR-${POWERLINE_SCM_STAGED_COLOR-"30"}}
		elif [[ "${SCM_DIRTY?}" -eq 2 ]]; then
			color=${SCM_THEME_PROMPT_UNSTAGED_COLOR-${POWERLINE_SCM_UNSTAGED_COLOR-"92"}}
		elif [[ "${SCM_DIRTY?}" -eq 1 ]]; then
			color=${SCM_THEME_PROMPT_DIRTY_COLOR-${POWERLINE_SCM_DIRTY_COLOR-"88"}}
		elif [[ "${SCM_DIRTY?}" -eq 0 ]]; then
			color=${SCM_THEME_PROMPT_CLEAN_COLOR-${POWERLINE_SCM_CLEAN_COLOR-"25"}}
		else
			color=${SCM_THEME_PROMPT_COLOR-${POWERLINE_SCM_CLEAN_COLOR-"25"}}
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
		printf '%s|%s' "${scm_prompt}" "${color}"
	fi
}

function __powerline_cwd_prompt() {
	printf '%s|%s' "\w" "${CWD_THEME_PROMPT_COLOR-"240"}"
}

function __powerline_hostname_prompt() {
	printf '%s|%s' "\h" "${HOST_THEME_PROMPT_COLOR-"0"}"
}

function __powerline_wd_prompt() {
	printf '%s|%s' "\W" "${CWD_THEME_PROMPT_COLOR-"240"}"
}

function __powerline_clock_prompt() {
	printf '%s|%s' "\D{${THEME_CLOCK_FORMAT-"%H:%M:%S"}}" "${CLOCK_THEME_PROMPT_COLOR-"240"}"
}

function __powerline_battery_prompt() {
	local color="" battery_status
	battery_status="$(battery_percentage 2> /dev/null)"

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
		if ac_adapter_connected; then
			battery_status="${BATTERY_AC_CHAR-"+"}${battery_status}"
		fi
		printf '%s|%s' "${battery_status}%" "${color}"
	fi
}

function __powerline_in_vim_prompt() {
	if [[ -n "${VIMRUNTIME:-}" ]]; then
		printf '%s|%s' "${IN_VIM_THEME_PROMPT_TEXT-"vim"}" "${IN_VIM_THEME_PROMPT_COLOR-"245"}"
	fi
}

function __powerline_aws_profile_prompt() {
	if [[ -n "${AWS_PROFILE:-}" ]]; then
		printf '%s%s|%s' "${AWS_PROFILE_CHAR-${POWERLINE_AWS_PROFILE_CHAR-"❲aws❳"}}" "${AWS_PROFILE}" "${AWS_PROFILE_PROMPT_COLOR-${POWERLINE_AWS_PROFILE_COLOR-"208"}}"
	fi
}

function __powerline_in_toolbox_prompt() {
	if [[ -f /run/.containerenv && -f /run/.toolboxenv ]]; then
		printf '%s|%s' "${IN_TOOLBOX_THEME_PROMPT_TEXT-"⬢"}" "${IN_TOOLBOX_THEME_PROMPT_COLOR-"125"}"
	fi
}

function __powerline_shlvl_prompt() {
	if [[ "${SHLVL}" -gt 1 ]]; then
		local prompt="${SHLVL_THEME_PROMPT_CHAR-"§"}"
		local level=$((SHLVL - 1))
		printf '%s|%s' "${prompt}${level}" "${SHLVL_THEME_PROMPT_COLOR-${HOST_THEME_PROMPT_COLOR-"0"}}"
	fi
}

function __powerline_dirstack_prompt() {
	if [[ "${#DIRSTACK[@]}" -gt 1 ]]; then
		local depth=$((${#DIRSTACK[@]} - 1))
		local prompt="${DIRSTACK_THEME_PROMPT_CHAR-${POWERLINE_DIRSTACK_CHAR-"←"}}"
		if [[ "${depth}" -ge 2 ]]; then
			prompt+="${depth}"
		fi
		printf '%s|%s' "${prompt}" "${DIRSTACK_THEME_PROMPT_COLOR-${POWERLINE_DIRSTACK_COLOR-${CWD_THEME_PROMPT_COLOR-${POWERLINE_CWD_COLOR-"240"}}}}"
	fi
}

function __powerline_history_number_prompt() {
	printf '%s%s|%s' "${HISTORY_NUMBER_THEME_PROMPT_CHAR-${POWERLINE_HISTORY_NUMBER_CHAR-"#"}}" '\!' "${HISTORY_NUMBER_THEME_PROMPT_COLOR-${POWERLINE_HISTORY_NUMBER_COLOR-"0"}}"
}

function __powerline_command_number_prompt() {
	printf '%s%s|%s' "${COMMAND_NUMBER_THEME_PROMPT_CHAR-${POWERLINE_COMMAND_NUMBER_CHAR-"#"}}" '\#' "${COMMAND_NUMBER_THEME_PROMPT_COLOR-${POWERLINE_COMMAND_NUMBER_COLOR-"0"}}"
}

function __powerline_duration_prompt() {
	local duration
	duration=$(_command_duration)
	if [[ -n "$duration" ]]; then
		printf '%s|%s' "${duration}" "${COMMAND_DURATION_PROMPT_COLOR?}"
	fi
}

function __powerline_left_segment() {
	local -a params
	IFS="|" read -ra params <<< "${1}"
	local pad_before_segment=" "

	#for seperator character
	if [[ "${SEGMENTS_AT_LEFT?}" -eq 0 ]]; then
		if [[ "${POWERLINE_COMPACT_BEFORE_FIRST_SEGMENT:-${POWERLINE_COMPACT:-0}}" -ne 0 ]]; then
			pad_before_segment=""
		fi
	else
		if [[ "${POWERLINE_COMPACT_AFTER_SEPARATOR:-${POWERLINE_COMPACT:-0}}" -ne 0 ]]; then
			pad_before_segment=""
		fi
		# Since the previous segment wasn't the last segment, add padding, if needed
		#
		if [[ "${POWERLINE_COMPACT_BEFORE_SEPARATOR:-${POWERLINE_COMPACT:-0}}" -eq 0 ]]; then
			LEFT_PROMPT+="$(set_color - "${LAST_SEGMENT_COLOR?}") ${normal?}"
		fi
		if [[ "${LAST_SEGMENT_COLOR?}" -eq "${params[1]:-}" ]]; then
			LEFT_PROMPT+="$(set_color - "${LAST_SEGMENT_COLOR?}")${POWERLINE_LEFT_SEPARATOR_SOFT- }${normal?}"
		else
			LEFT_PROMPT+="$(set_color "${LAST_SEGMENT_COLOR?}" "${params[1]:-}")${POWERLINE_LEFT_SEPARATOR- }${normal?}"
		fi
	fi

	#change here to cahnge fg color
	LEFT_PROMPT+="$(set_color - "${params[1]:-}")${pad_before_segment}${params[0]}${normal?}"
	#seperator char color == current bg
	LAST_SEGMENT_COLOR="${params[1]:-}"
	((SEGMENTS_AT_LEFT += 1))
}

function __powerline_left_last_segment_padding() {
	LEFT_PROMPT+="$(set_color - "${LAST_SEGMENT_COLOR?}") ${normal?}"
}

function __powerline_last_status_prompt() {
	if [[ "${1?}" -ne 0 ]]; then
		printf '%s|%s' "${1}" "${LAST_STATUS_THEME_PROMPT_COLOR-"52"}"
	fi
}

function __powerline_prompt_command() {
	local last_status="$?" ## always the first
	local beginning_of_line='\[\e[G\]'
	local info prompt_color segment prompt

	local LEFT_PROMPT=""
	local SEGMENTS_AT_LEFT=0
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

	if [[ "${last_status}" -ne 0 ]]; then
		__powerline_left_segment "$(__powerline_last_status_prompt "${last_status}")"
	fi

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

	prompt="${prompt_color}${PROMPT_CHAR-${POWERLINE_PROMPT_CHAR-\\$}}${normal?}"
	if [[ "${POWERLINE_COMPACT_PROMPT:-${POWERLINE_COMPACT:-0}}" -eq 0 ]]; then
		prompt+=" "
	fi

	PS1="${beginning_of_line}${normal?}${LEFT_PROMPT}${prompt}"
}
