# shellcheck shell=bash

function _git-symbolic-ref() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	git symbolic-ref -q HEAD 2> /dev/null

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}



# When on a branch, this is often the same as _git-commit-description,
# but this can be different when two branches are pointing to the
# same commit. _git-branch is used to explicitly choose the checked-out
# branch.
function _git-branch() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	if [[ "${SCM_GIT_GITSTATUS_RAN:-}" == "true" ]] 
     then
		if [[ -n "${VCS_STATUS_LOCAL_BRANCH:-}" ]] 
     then
			echo "${VCS_STATUS_LOCAL_BRANCH}"
		else
			return 1
		fi
	else
		git symbolic-ref -q --short HEAD 2> /dev/null || return 1
	fi

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}



function _git-tag() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	if [[ "${SCM_GIT_GITSTATUS_RAN:-}" == "true" ]] 
     then
		if [[ -n "${VCS_STATUS_TAG:-}" ]] 
     then
			echo "${VCS_STATUS_TAG}"
		fi
	else
		git describe --tags --exact-match 2> /dev/null
	fi

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}



function _git-commit-description() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	git describe --contains --all 2> /dev/null

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}



function _git-short-sha() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	if [[ "${SCM_GIT_GITSTATUS_RAN:-}" == "true" ]] 
     then
		echo "${VCS_STATUS_COMMIT:0:7}"
	else
		git rev-parse --short HEAD
	fi

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}



# Try the checked-out branch first to avoid collision with branches pointing to the same ref.
function _git-friendly-ref() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	if [[ "${SCM_GIT_GITSTATUS_RAN:-}" == "true" ]] 
     then
		_git-branch || _git-tag || _git-short-sha # there is no tag based describe output in gitstatus
	else
		_git-branch || _git-tag || _git-commit-description || _git-short-sha
	fi

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}



function _git-num-remotes() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	git remote | wc -l

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}



function _git-upstream() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	local ref
	ref="$(_git-symbolic-ref)" || return 1
	git for-each-ref --format="%(upstream:short)" "${ref}"

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}



function _git-upstream-remote() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	local upstream branch
	upstream="$(_git-upstream)" || return 1

	branch="$(_git-upstream-branch)" || return 1
	echo "${upstream%"/${branch}"}"

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}



function _git-upstream-branch() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	local ref
	ref="$(_git-symbolic-ref)" || return 1

	# git versions < 2.13.0 do not support "strip" for upstream format
	# regex replacement gives the wrong result for any remotes with slashes in the name,
	# so only use when the strip format fails.
	git for-each-ref --format="%(upstream:strip=3)" "${ref}" 2> /dev/null || git for-each-ref --format="%(upstream)" "${ref}" | sed -e "s/.*\/.*\/.*\///"

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}



function _git-upstream-behind-ahead() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	git rev-list --left-right --count "$(_git-upstream)...HEAD" 2> /dev/null

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}



function _git-upstream-branch-gone() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	[[ "$(git status -s -b | sed -e 's/.* //')" == "[gone]" ]]

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}



function _git-hide-status() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	[[ "$(git config --get bash-it.hide-status)" == "1" ]]

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}



function _git-status() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	local git_status_flags=
	if [[ "${SCM_GIT_IGNORE_UNTRACKED:-}" == "true" ]] 
     then
		git_status_flags='-uno'
	fi
	git status --porcelain "${git_status_flags:---}" 2> /dev/null

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}



function _git-status-counts() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	_git-status | awk '
  BEGIN {
    untracked=0;
    unstaged=0;
    staged=0;
  }
  {
    if ($0 ~ /^\?\? .+/) {
      untracked += 1
    } else {
      if ($0 ~ /^.[^ ] .+/) {
        unstaged += 1
      }
      if ($0 ~ /^[^ ]. .+/) {
        staged += 1
      }
    }
  }
  END {
    print untracked "\t" unstaged "\t" staged
  }'

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}



function _git-remote-info() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	local same_branch_name="" branch_prefix
	# prompt handling only, reimplement because patching the routine below gets ugly
	if [[ "${SCM_GIT_GITSTATUS_RAN:-}" == "true" ]] 
     then
		[[ "${VCS_STATUS_REMOTE_NAME?}" == "" ]] && return
		[[ "${VCS_STATUS_LOCAL_BRANCH?}" == "${VCS_STATUS_REMOTE_BRANCH?}" ]] && same_branch_name=true
		# no multiple remote support in gitstatusd
		if [[ "${SCM_GIT_SHOW_REMOTE_INFO:-}" == "true" || "${SCM_GIT_SHOW_REMOTE_INFO:-}" == "auto" ]] 
     then
			if [[ ${same_branch_name:-} != "true" ]] 
     then
				remote_info="${VCS_STATUS_REMOTE_NAME?}/${VCS_STATUS_REMOTE_BRANCH?}"
			else
				remote_info="${VCS_STATUS_REMOTE_NAME?}"
			fi
		elif [[ ${same_branch_name:-} != "true" ]] 
     then
			remote_info="${VCS_STATUS_REMOTE_BRANCH?}"
		fi
		if [[ -n "${remote_info:-}" ]] 
     then
			# no support for gone remote branches in gitstatusd
			branch_prefix="${SCM_THEME_BRANCH_TRACK_PREFIX:-}"
			echo "${branch_prefix}${remote_info:-}"
		fi
	else
		[[ "$(_git-upstream)" == "" ]] && return

		[[ "$(_git-branch)" == "$(_git-upstream-branch)" ]] && same_branch_name=true
		if [[ ("${SCM_GIT_SHOW_REMOTE_INFO}" == "auto" && "$(_git-num-remotes)" -ge 2) ||
		"${SCM_GIT_SHOW_REMOTE_INFO}" == "true" ]] 
     then
			if [[ ${same_branch_name:-} != "true" ]] 
     then
				# shellcheck disable=SC2016
				remote_info='$(_git-upstream)'
			else
				remote_info="$(_git-upstream-remote)"
			fi
		elif [[ ${same_branch_name:-} != "true" ]] 
     then
			# shellcheck disable=SC2016
			remote_info='$(_git-upstream-branch)'
		fi
		if [[ -n "${remote_info:-}" ]] 
     then
			local branch_prefix
			if _git-upstream-branch-gone 
     then
				branch_prefix="${SCM_THEME_BRANCH_GONE_PREFIX:-}"
			else
				branch_prefix="${SCM_THEME_BRANCH_TRACK_PREFIX:-}"
			fi
			echo "${branch_prefix}${remote_info:-}"
		fi
	fi

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}

