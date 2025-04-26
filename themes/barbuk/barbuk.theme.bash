# shellcheck shell=bash
# shellcheck disable=SC2034 # Expected behavior for themes.

# Prompt defaut configuration
BARBUK_PROMPT=${BARBUK_PROMPT:="git-uptream-remote-logo ssh path scm python_venv ruby node terraform cloud duration exit"}

# Theme custom glyphs
# SCM
SCM_GIT_CHAR_GITLAB=${BARBUK_GITLAB_CHAR:='  '}
SCM_GIT_CHAR_BITBUCKET=${BARBUK_BITBUCKET_CHAR:='  '}
SCM_GIT_CHAR_GITHUB=${BARBUK_GITHUB_CHAR:='  '}
SCM_GIT_CHAR_DEFAULT=${BARBUK_GIT_DEFAULT_CHAR:='  '}
SCM_GIT_CHAR_ICON_BRANCH=${BARBUK_GIT_BRANCH_ICON:=''}
SCM_HG_CHAR=${BARBUK_HG_CHAR:='☿ '}
SCM_SVN_CHAR=${BARBUK_SVN_CHAR:='⑆ '}
SCM_THEME_CURRENT_USER_PREFFIX=${normal?}${BARBUK_CURRENT_USER_PREFFIX:='  '}
# Exit code
EXIT_CODE_ICON=${BARBUK_EXIT_CODE_ICON:=' '}
# Programming and tools
PYTHON_VENV_CHAR=${BARBUK_PYTHON_VENV_CHAR:=' '}
RUBY_CHAR=${BARBUK_RUBY_CHAR:=' '}
NODE_CHAR=${BARBUK_NODE_CHAR:=' '}
TERRAFORM_CHAR=${BARBUK_TERRAFORM_CHAR:="❲t❳ "}
# Cloud
AWS_PROFILE_CHAR=${BARBUK_AWS_PROFILE_CHAR:=" aws "}
SCALEWAY_PROFILE_CHAR=${BARBUK_SCALEWAY_PROFILE_CHAR:=" scw "}
GCLOUD_CHAR=${BARBUK_GCLOUD_CHAR:=" google "}

# Command duration
: "${COMMAND_DURATION_MIN_SECONDS:=1}"
: "${COMMAND_DURATION_COLOR:="${normal?}"}"

# Ssh user and hostname display
SSH_INFO=${BARBUK_SSH_INFO:=true}
HOST_INFO=${BARBUK_HOST_INFO:=long}

# Bash-it default glyphs overrides
SCM_NONE_CHAR=
SCM_THEME_PROMPT_DIRTY=" ${bold_red?}✗"
SCM_THEME_PROMPT_CLEAN=" ${bold_green?}✓"
SCM_THEME_PROMPT_PREFIX="|"
SCM_THEME_PROMPT_SUFFIX="${green?}| "
SCM_GIT_BEHIND_CHAR="${bold_red?}↓${normal?}"
SCM_GIT_AHEAD_CHAR="${bold_green?}↑${normal?}"
SCM_GIT_UNTRACKED_CHAR="⌀"
SCM_GIT_UNSTAGED_CHAR="${bold_yellow?}•${normal?}"
SCM_GIT_STAGED_CHAR="${bold_green?}+${normal?}"
GIT_THEME_PROMPT_DIRTY=" ${bold_red?}✗"
GIT_THEME_PROMPT_CLEAN=" ${bold_green?}✓"
GIT_THEME_PROMPT_PREFIX="${cyan?}"
GIT_THEME_PROMPT_SUFFIX="${cyan?}"
SCM_THEME_BRANCH_TRACK_PREFIX="${normal?} ⤏  ${cyan?}"
SCM_THEME_CURRENT_USER_PREFFIX='  '
SCM_GIT_SHOW_CURRENT_USER='false'
NVM_THEME_PROMPT_PREFIX=''
NVM_THEME_PROMPT_SUFFIX=''
RVM_THEME_PROMPT_PREFIX=''
RVM_THEME_PROMPT_SUFFIX=''
RBENV_THEME_PROMPT_PREFIX=' '
RBENV_THEME_PROMPT_SUFFIX=''
RBFU_THEME_PROMPT_PREFIX=''
RBFU_THEME_PROMPT_SUFFIX=''

function _git-uptream-remote-logo() {
	[[ -z "$(_git-upstream)" ]] && SCM_GIT_CHAR="${SCM_GIT_CHAR_DEFAULT:-}"

	local remote remote_domain
	remote="$(_git-upstream-remote)"
	remote_domain="$(git config --get remote."${remote}".url | awk -F'[@:.]' '{print $2}')"

	# remove // suffix for https:// url
	remote_domain="${remote_domain//\//}"

	case "${remote_domain}" in
		github) SCM_GIT_CHAR="${SCM_GIT_CHAR_GITHUB:-}" ;;
		gitlab) SCM_GIT_CHAR="${SCM_GIT_CHAR_GITLAB:-}" ;;
		bitbucket) SCM_GIT_CHAR="${SCM_GIT_CHAR_BITBUCKET:-}" ;;
		*) SCM_GIT_CHAR="${SCM_GIT_CHAR_DEFAULT:-}" ;;
	esac

	echo "${purple?}$(scm_char)"
}

function git_prompt_info() {
	git_prompt_vars
	echo -e " on ${SCM_GIT_CHAR_ICON_BRANCH:-} ${SCM_PREFIX:-}${SCM_BRANCH:-}${SCM_STATE:-}${SCM_GIT_AHEAD:-}${SCM_GIT_BEHIND:-}${SCM_GIT_STASH:-}${SCM_SUFFIX:-}"
}

function _exit-code() {
	if [[ "${1:-}" -ne 0 ]]; then
		exit_code=" ${purple?}${EXIT_CODE_ICON:-}${yellow?}${exit_code:-}${bold_orange?}"
	else
		exit_code="${bold_green?}"
	fi
}

function _prompt() {
	local exit_code="$?" wrap_char=' ' dir_color=$green ssh_info='' python_venv='' host command_duration=
	local scm_char scm_prompt_info

	command_duration="$(_command_duration)"
}

function __exit_prompt() {
	if [[ "$exit_code" -ne 0 ]]; then
		echo "${purple?}${EXIT_CODE_ICON}${yellow?}${exit_code}${bold_orange?} "
	else
		echo "${bold_green}"
	fi
}

function __aws_profile_prompt() {
	if [[ -n "${AWS_PROFILE}" ]]; then
		echo -n "${bold_purple?}${AWS_PROFILE_CHAR}${normal?}${AWS_PROFILE} "
	fi
}

function __scaleway_profile_prompt() {
	if [[ -n "${SCW_PROFILE}" ]]; then
		echo -n "${bold_purple?}${SCALEWAY_PROFILE_CHAR}${normal?}${SCW_PROFILE} "
	fi
}

function __gcloud_prompt() {
	local active_gcloud_account=""

	active_gcloud_account="$(active_gcloud_account_prompt)"
	[[ -n "${active_gcloud_account}" ]] && echo "${bold_purple?}${GCLOUD_CHAR}${normal?}${active_gcloud_account} "
}

function __cloud_prompt() {
	__aws_profile_prompt
	__scaleway_profile_prompt
	__gcloud_prompt
}

function __terraform_prompt() {
	local terraform_workspace=""

	if [ -d .terraform ]; then
		terraform_workspace="$(terraform_workspace_prompt)"
		[[ -n "${terraform_workspace}" ]] && echo "${bold_purple?}${TERRAFORM_CHAR}${normal?}${terraform_workspace} "
	fi
}

function __node_prompt() {
	local node_version=""

	node_version="$(node_version_prompt)"
	[[ -n "${node_version}" ]] && echo "${bold_purple?}${NODE_CHAR}${normal?}${node_version} "
}

function __ruby_prompt() {
	local ruby_version=""

	ruby_version="$(ruby_version_prompt)"
	[[ -n "${ruby_version}" ]] && echo "${bold_purple?}${RUBY_CHAR}${normal?}${ruby_version} "
}

function __ssh_prompt() {
	# Detect ssh
	if [[ -n "${SSH_CONNECTION:-}" && "${SSH_INFO:-}" == true ]]; then
		if [[ "${HOST_INFO:-}" == long ]]; then
			host="\H"
		else
			host="\h"
		fi
		ssh_info="${bold_blue?}\u${bold_orange?}@${cyan?}$host ${bold_orange?}in"
	fi
}

function __python_venv_prompt() {
	# Detect python venv
	if [[ -n "${CONDA_DEFAULT_ENV:-}" ]]; then
		python_venv="${PYTHON_VENV_CHAR:-}${CONDA_DEFAULT_ENV:-} "
	elif [[ -n "${VIRTUAL_ENV:-}" ]]; then
		python_venv="$PYTHON_VENV_CHAR${VIRTUAL_ENV##*/} "
	fi

	scm_char="$(scm_char)"
	scm_prompt_info="$(scm_prompt_info)"
	PS1="\\n${ssh_info} ${purple}${scm_char}${python_venv}${dir_color}\\w${normal}${scm_prompt_info}${command_duration}${exit_code}"
}

function __path_prompt() {
	local dir_color=${green?}
	# Detect root shell
	if [ "$(whoami)" = root ]; then
		dir_color=${red?}
	fi

	echo "${dir_color}\w${normal} "
}

function __scm_prompt() {
	scm_prompt_info
}

function __duration_prompt() {
	[[ -n "$command_duration" ]] && echo "${command_duration} "
}

function __prompt-command() {
	exit_code="$?"
	command_duration=$(_command_duration)
	local wrap_char

	# Generate prompt
	PS1="\n "
	for segment in $BARBUK_PROMPT; do
		local info
		info="$(__"${segment}"_prompt)"
		[[ -n "${info}" ]] && PS1+="${info}"
	done

	# Cut prompt when it's too long
	if [[ ${#PS1} -gt $((COLUMNS * 2)) ]]; then
		wrap_char="\n"
	fi

	PS1="${PS1}${wrap_char}❯${normal} "
}

safe_append_prompt_command __prompt-command
