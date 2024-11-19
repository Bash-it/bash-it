# shellcheck shell=bats
# shellcheck disable=SC2034
# shellcheck disable=SC2016

load "${MAIN_BASH_IT_DIR?}/test/test_helper.bash"

function local_setup_file() {
	setup_libs "colors" #"theme"
	load "${BASH_IT?}/themes/base.theme.bash"
	load "${BASH_IT?}/themes/githelpers.theme.bash"
}

add_commit() {
	local file_name="general-${RANDOM}"
	touch "${file_name}"
	echo "" >> "${file_name}"
	git add "${file_name}"
	git commit -m"message"
}

enter_new_git_repo() {
	repo="$(setup_repo)"
	pushd "${repo}" || return
}

setup_repo() {
	upstream="$(mktemp -d)"
	pushd "$upstream" > /dev/null || return
	git init . > /dev/null

	echo "$upstream"
}

setup_repo_with_upstream() {
	upstream="$(setup_repo)"
	pushd "$upstream" > /dev/null || return
	add_commit > /dev/null
	git checkout -b branch-two
	git checkout -b gone-branch
	git checkout master
	popd > /dev/null || return

	downstream="$(setup_repo)"
	pushd "$downstream" > /dev/null || return
	add_commit > /dev/null
	git remote add my-remote "$upstream"
	git fetch my-remote
	git branch -u my-remote/master > /dev/null
	popd > /dev/null || return

	pushd "$upstream" > /dev/null || return
	git branch -d gone-branch > /dev/null
	popd > /dev/null || return

	pushd "$downstream" > /dev/null || return
	git fetch my-remote
	popd > /dev/null || return

	echo "$downstream"
}

@test 'themes base: Git: when tracking a remote branch: it shows the commits ahead and behind' {
	pre='$(_git-friendly-ref)'

	remote="$(setup_repo)"
	pushd "$remote" || return
	add_commit
	add_commit
	popd || return

	clone="$(mktemp -d)"
	pushd "$clone" || return
	git clone "$remote" clone
	cd clone

	SCM_GIT_SHOW_COMMIT_COUNT=true

	git_prompt_vars
	assert_equal "${SCM_BRANCH?}" "${pre}"

	add_commit

	git_prompt_vars
	assert_equal "${SCM_BRANCH?}" "${pre} ↑1"

	add_commit

	git_prompt_vars
	assert_equal "${SCM_BRANCH?}" "${pre} ↑2"
	popd || return

	pushd "$remote" || return
	add_commit
	add_commit
	add_commit
	popd || return

	pushd "$clone/clone" || return
	git fetch

	git_prompt_vars
	assert_equal "${SCM_BRANCH?}" "${pre} ↑2 ↓3"

	git reset HEAD~2 --hard

	SCM_GIT_BEHIND_CHAR="↓"
	git_prompt_vars
	assert_equal "${SCM_BRANCH?}" "${pre} ↓3"
}

@test 'themes base: Git: when stashes exist: it shows the number of stashes' {
	pre='$(_git-friendly-ref)'

	enter_new_git_repo
	add_commit

	touch file
	git add file
	git stash

	SCM_GIT_SHOW_STASH_INFO=true

	git_prompt_vars
	assert_equal "${SCM_BRANCH?}" "${pre} {1}"

	touch file2
	git add file2
	git stash

	git_prompt_vars
	assert_equal "${SCM_BRANCH?}" "${pre} {2}"
}

@test 'themes base: Git: remote info: when there is no upstream remote: is empty' {
	pre='$(_git-friendly-ref)'
	post=" ↑1 ↓1"

	enter_new_git_repo
	add_commit

	git_prompt_vars
	assert_equal "${SCM_BRANCH?}" "${pre}"
}

@test 'themes base: Git: remote info: when SCM_GIT_SHOW_REMOTE_INFO is true: includes the remote' {
	pre='$(_git-friendly-ref) → '
	eval_pre="master → "
	post=" ↑1 ↓1"

	repo="$(setup_repo_with_upstream)"
	pushd "${repo}" || return

	SCM_GIT_SHOW_REMOTE_INFO=true
	SCM_GIT_SHOW_COMMIT_COUNT=true

	git_prompt_vars
	assert_equal "${SCM_BRANCH?}" "${pre}my-remote${post}"

	git branch -u my-remote/branch-two

	git_prompt_vars
	assert_equal "${SCM_BRANCH?}" "${pre}"'$(_git-upstream)'"${post}"
	assert_equal "$(eval "echo \"${SCM_BRANCH?}\"")" "${eval_pre}my-remote/branch-two${post}"
}

@test 'themes base: Git: remote info: when SCM_GIT_SHOW_REMOTE_INFO is auto: includes the remote when more than one remote' {
	pre='$(_git-friendly-ref)'
	eval_pre="master"
	post=" ↑1 ↓1"

	repo="$(setup_repo_with_upstream)"
	pushd "${repo}" || return

	SCM_GIT_SHOW_REMOTE_INFO=auto
	SCM_GIT_SHOW_COMMIT_COUNT=true

	git_prompt_vars
	assert_equal "${SCM_BRANCH?}" "${pre}${post}"

	pre="${pre} → "
	eval_pre="${eval_pre} → "
	git branch -u my-remote/branch-two

	git_prompt_vars
	assert_equal "${SCM_BRANCH?}" "${pre}"'$(_git-upstream-branch)'"${post}"
	assert_equal "$(eval "echo \"${SCM_BRANCH?}\"")" "${eval_pre}branch-two${post}"

	git remote add second-remote "$(mktemp -d)"
	git branch -u my-remote/master

	git_prompt_vars
	assert_equal "${SCM_BRANCH?}" "${pre}my-remote${post}"

	git branch -u my-remote/branch-two

	git_prompt_vars
	assert_equal "${SCM_BRANCH?}" "${pre}"'$(_git-upstream)'"${post}"
	assert_equal "$(eval "echo \"${SCM_BRANCH?}\"")" "${eval_pre}my-remote/branch-two${post}"
}

@test 'themes base: Git: remote info: when SCM_GIT_SHOW_REMOTE_INFO is false: never include the remote' {
	pre='$(_git-friendly-ref)'
	eval_pre="master"
	post=" ↑1 ↓1"

	repo="$(setup_repo_with_upstream)"
	pushd "${repo}" || return
	git remote add second-remote "$(mktemp -d)"
	git remote add third-remote "$(mktemp -d)"

	SCM_GIT_SHOW_REMOTE_INFO=false
	SCM_GIT_SHOW_COMMIT_COUNT=true

	git_prompt_vars
	assert_equal "${SCM_BRANCH?}" "${pre}${post}"

	pre="${pre} → "
	eval_pre="${eval_pre} → "
	git branch -u my-remote/branch-two

	git_prompt_vars
	assert_equal "${SCM_BRANCH?}" "${pre}"'$(_git-upstream-branch)'"${post}"
	assert_equal "$(eval "echo \"${SCM_BRANCH?}\"")" "${eval_pre}branch-two${post}"
}

@test 'themes base: Git: remote info: when showing remote info: show if upstream branch is gone' {
	pre='$(_git-friendly-ref)'
	post=" ↑1 ↓1"

	repo="$(setup_repo_with_upstream)"
	pushd "${repo}" || return

	SCM_GIT_SHOW_REMOTE_INFO=true
	SCM_GIT_SHOW_COMMIT_COUNT=true

	git_prompt_vars
	assert_equal "${SCM_BRANCH?}" "${pre} → my-remote${post}"

	git checkout gone-branch
	git fetch --prune --all

	git_prompt_vars
	assert_equal "${SCM_BRANCH?}" "${pre} ⇢ my-remote"
}

@test 'themes base: Git: git friendly ref: when a branch is checked out: shows that branch' {
	enter_new_git_repo

	git_prompt_vars
	assert_equal "$(eval "echo \"${SCM_BRANCH?}\"")" "master"

	git checkout -b second-branch

	git_prompt_vars
	assert_equal "$(eval "echo \"${SCM_BRANCH?}\"")" "second-branch"
}

@test 'themes base: Git: git friendly ref: when a branch is not checked out: shows that branch' {
	enter_new_git_repo

	git_prompt_vars
	assert_equal "$(eval "echo \"${SCM_BRANCH?}\"")" "master"

	git checkout -b second-branch

	git_prompt_vars
	assert_equal "$(eval "echo \"${SCM_BRANCH?}\"")" "second-branch"
}

@test 'themes base: Git: git friendly ref: when detached: commit has branch and tag: show a tag' {
	enter_new_git_repo
	add_commit
	git tag first-tag
	git checkout -b second-branch
	add_commit
	git checkout HEAD~1

	git_prompt_vars
	assert_equal "$(eval "echo \"${SCM_BRANCH?}\"")" "tag:first-tag"
}

@test 'themes base: Git: git friendly ref: when detached: commit has branch and no tag: show a branch' {
	enter_new_git_repo
	add_commit
	git checkout -b second-branch
	add_commit
	git checkout HEAD~1

	git_prompt_vars
	assert_equal "$(eval "echo \"${SCM_BRANCH?}\"")" "detached:master"
}

@test 'themes base: Git: git friendly ref: when detached with no branch or tag: commit is parent to a named ref: show relative name' {
	enter_new_git_repo
	add_commit
	add_commit
	git checkout HEAD~1

	git_prompt_vars
	assert_equal "$(eval "echo \"${SCM_BRANCH?}\"")" "detached:master~1"
}

@test 'themes base: Git: git friendly ref: when detached with no branch or tag: commit is not parent to a named ref: show short sha' {
	enter_new_git_repo
	add_commit
	add_commit
	sha="$(git rev-parse --short HEAD)"
	git reset --hard HEAD~1
	git checkout "$sha"

	git_prompt_vars
	assert_equal "$(eval "echo \"${SCM_BRANCH?}\"")" "detached:$sha"
}

@test 'themes base: Git: git friendly ref: shows staged, unstaged, and untracked file counts' {
	pre='$(_git-friendly-ref)'

	enter_new_git_repo
	echo "line1" > file1
	echo "line1" > file2
	echo "line1" > file3
	echo "line1" > file4
	git add .
	git commit -m"commit1"

	git_prompt_vars
	assert_equal "${SCM_STATE?}" " ✓"

	echo "line2" >> file1
	git add file1

	SCM_GIT_SHOW_DETAILS=true

	git_prompt_vars
	assert_equal "${SCM_BRANCH?}" "${pre} S:1"
	assert_equal "${SCM_STATE?}" " ✗"
	assert_equal "${SCM_DIRTY?}" "3"

	echo "line2" >> file2
	echo "line2" >> file3
	echo "line2" >> file4

	git_prompt_vars
	assert_equal "${SCM_BRANCH?}" "${pre} S:1 U:3"
	assert_equal "${SCM_DIRTY?}" "2"

	echo "line1" > newfile5
	echo "line1" > newfile6

	git_prompt_vars
	assert_equal "${SCM_BRANCH?}" "${pre} S:1 U:3 ?:2"
	assert_equal "${SCM_DIRTY?}" "1"

	git config bash-it.hide-status 1

	SCM_DIRTY='nope'
	git_prompt_vars
	assert_equal "${SCM_BRANCH?}" "${pre}"
	assert_equal "${SCM_DIRTY?}" "nope"
}

@test 'themes base: Git: git user info: shows user initials' {
	pre='$(_git-friendly-ref)'

	enter_new_git_repo
	git config user.name "Cool User"

	git_prompt_vars
	assert_equal "${SCM_BRANCH?}" "${pre}"

	SCM_GIT_SHOW_CURRENT_USER=true

	git_prompt_vars
	assert_equal "${SCM_BRANCH?}" "${pre} ☺︎ cu"

	git config user.name "Çool Üser"

	git_prompt_vars
	assert_equal "${SCM_BRANCH?}" "${pre} ☺︎ çü"

	# show initials set by `git pair`

	git config user.initials "ab cd"

	git_prompt_vars
	assert_equal "${SCM_BRANCH?}" "${pre} ☺︎ ab+cd"
}
