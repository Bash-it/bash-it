#!/usr/bin/env bash

function _git-symbolic-ref {
 git symbolic-ref -q HEAD 2> /dev/null
}

# When on a branch, this is often the same as _git-commit-description,
# but this can be different when two branches are pointing to the
# same commit. _git-branch is used to explicitly choose the checked-out
# branch.
function _git-branch {
  if [[ "${SCM_GIT_GITSTATUSD_RAN}" == "true" ]]; then
    test -n "${VCS_STATUS_LOCAL_BRANCH}" && echo "${VCS_STATUS_LOCAL_BRANCH}" || return 1
  else 
    git symbolic-ref -q --short HEAD 2> /dev/null || return 1
  fi
}

function _git-tag {
  if [[ "${SCM_GIT_GITSTATUSD_RAN}" == "true" ]]; then
    test -n "${VCS_STATUS_TAG}" && echo "${VCS_STATUS_TAG}"
  else 
    git describe --tags --exact-match 2> /dev/null
  fi
}

function _git-commit-description {
  git describe --contains --all 2> /dev/null
}

function _git-short-sha {
  if [[ "${SCM_GIT_GITSTATUSD_RAN}" == "true" ]]; then
    echo ${VCS_STATUS_COMMIT:0:7}
  else
    git rev-parse --short HEAD
  fi
}

# Try the checked-out branch first to avoid collision with branches pointing to the same ref.
function _git-friendly-ref {
  if [[ "${SCM_GIT_GITSTATUSD_RAN}" == "true" ]]; then
    _git-branch || _git-tag || _git-short-sha # there is no tag based describe output in gitstatusd
  else 
    _git-branch || _git-tag || _git-commit-description || _git-short-sha
  fi
}

function _git-num-remotes {
  git remote | wc -l
}

function _git-upstream {
  local ref
  ref="$(_git-symbolic-ref)" || return 1
  git for-each-ref --format="%(upstream:short)" "${ref}"
}

function _git-upstream-remote {
  local upstream
  upstream="$(_git-upstream)" || return 1

  local branch
  branch="$(_git-upstream-branch)" || return 1
  echo "${upstream%"/${branch}"}"
}

function _git-upstream-branch {
  local ref
  ref="$(_git-symbolic-ref)" || return 1

  # git versions < 2.13.0 do not support "strip" for upstream format
  # regex replacement gives the wrong result for any remotes with slashes in the name,
  # so only use when the strip format fails.
  git for-each-ref --format="%(upstream:strip=3)" "${ref}" 2> /dev/null || git for-each-ref --format="%(upstream)" "${ref}" | sed -e "s/.*\/.*\/.*\///"
}

function _git-upstream-behind-ahead {
  git rev-list --left-right --count "$(_git-upstream)...HEAD" 2> /dev/null
}

function _git-upstream-branch-gone {
  [[ "$(git status -s -b | sed -e 's/.* //')" == "[gone]" ]]
}

function _git-hide-status {
  [[ "$(git config --get bash-it.hide-status)" == "1" ]]
}

function _git-status {
  local git_status_flags=
  [[ "${SCM_GIT_IGNORE_UNTRACKED}" = "true" ]] && git_status_flags='-uno' || true
  git status --porcelain ${git_status_flags} 2> /dev/null
}

function _git-status-counts {
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
}

function _git-remote-info {

  if [[ "${SCM_GIT_GITSTATUSD_RAN}" == "true" ]]; then # prompt handling only, reimplement because patching the routine below gets ugly
    [[ "${VCS_STATUS_REMOTE_NAME}" == "" ]] && return || true
    [[ "${VCS_STATUS_LOCAL_BRANCH}" == "${VCS_STATUS_REMOTE_BRANCH}" ]] && local same_branch_name=true || true
    local same_branch_name=
    [[ "${VCS_STATUS_LOCAL_BRANCH}" == "${VCS_STATUS_REMOTE_BRANCH}" ]] && same_branch_name=true
    if [[ "${SCM_GIT_SHOW_REMOTE_INFO}" = "true" ]] || [[ "${SCM_GIT_SHOW_REMOTE_INFO}" = "auto" ]]; then # no multiple remote support in gitstatusd
      if [[ "${same_branch_name}" != "true" ]]; then
        remote_info="\${VCS_STATUS_REMOTE_NAME}"
      else
        remote_info="${VCS_STATUS_REMOTE_NAME}/${VCS_STATUS_REMOTE_BRANCH}"
      fi
    elif [[ ${same_branch_name} != "true" ]]; then
      remote_info="\${VCS_STATUS_REMOTE_BRANCH}"
    fi
    if [[ -n "${remote_info}" ]];then
      local branch_prefix 
      branch_prefix="${SCM_THEME_BRANCH_TRACK_PREFIX}" # no support for gone remote branches in gitstatusd
      echo "${branch_prefix}${remote_info}"
    fi
  else 
    [[ "$(_git-upstream)" == "" ]] && return || true

    [[ "$(_git-branch)" == "$(_git-upstream-branch)" ]] && local same_branch_name=true || true
    local same_branch_name=
    [[ "$(_git-branch)" == "$(_git-upstream-branch)" ]] && same_branch_name=true
    if ([[ "${SCM_GIT_SHOW_REMOTE_INFO}" = "auto" ]] && [[ "$(_git-num-remotes)" -ge 2 ]]) ||
        [[ "${SCM_GIT_SHOW_REMOTE_INFO}" = "true" ]]; then
      if [[ "${same_branch_name}" != "true" ]]; then
        remote_info="\$(_git-upstream)"
      else
        remote_info="$(_git-upstream-remote)"
      fi
    elif [[ ${same_branch_name} != "true" ]]; then
      remote_info="\$(_git-upstream-branch)"
    fi
    if [[ -n "${remote_info}" ]];then
      local branch_prefix
      if _git-upstream-branch-gone; then
        branch_prefix="${SCM_THEME_BRANCH_GONE_PREFIX}"
      else
        branch_prefix="${SCM_THEME_BRANCH_TRACK_PREFIX}"
      fi
      echo "${branch_prefix}${remote_info}"
    fi
  fi
}

# Unused by bash-it, present for API compatibility
function git_status_summary {
  awk '
  BEGIN {
    untracked=0;
    unstaged=0;
    staged=0;
  }
  {
    if (!after_first && $0 ~ /^##.+/) {
      print $0
      seen_header = 1
    } else if ($0 ~ /^\?\? .+/) {
      untracked += 1
    } else {
      if ($0 ~ /^.[^ ] .+/) {
        unstaged += 1
      }
      if ($0 ~ /^[^ ]. .+/) {
        staged += 1
      }
    }
    after_first = 1
  }
  END {
    if (!seen_header) {
      print
    }
    print untracked "\t" unstaged "\t" staged
  }'
}
