# shellcheck shell=bash

function setup_file() {
	common_setup_file
}

function common_setup_file() {
	# export *everything* to subshells, needed to support tests
	set -a

	# Locate ourselves for easy reference.
	TEST_MAIN_DIR="${MAIN_BASH_IT_DIR:-${BATS_TEST_DIRNAME?}/../..}/test"
	TEST_DEPS_DIR="${MAIN_BASH_IT_DIR:-${TEST_MAIN_DIR}/..}/test_lib"

	# Load the BATS modules we use:
	load "${TEST_DEPS_DIR}/bats-support/load.bash"
	load "${TEST_DEPS_DIR}/bats-assert/load.bash"
	load "${TEST_DEPS_DIR}/bats-file/load.bash"

	# shellcheck disable=SC2034 # Clear any inherited environment:
	XDG_DUMMY="" BASH_IT_DUMMY=""    # avoid possible invalid reference:
	unset "${!XDG_@}" "${!BASH_IT@}" # unset all BASH_IT* and XDG_* variables
	unset GIT_HOSTING NGINX_PATH IRC_CLIENT TODO SCM_CHECK

	# Some tools, e.g. `git` use configuration files from the $HOME directory,
	# which interferes with our tests. The only way to keep `git` from doing
	# this seems to set HOME explicitly to a separate location.
	# Refer to https://git-scm.com/docs/git-config#FILES.
	readonly HOME="${BATS_SUITE_TMPDIR?}"
	mkdir -p "${HOME}"

	# For `git` tests to run well, user name and email need to be set.
	# Refer to https://git-scm.com/docs/git-commit#_commit_information.
	# This goes to the test-specific config, due to the $HOME overridden above.
	git config --global user.name "Bash It BATS Runner"
	git config --global user.email "bats@bash.it"
	git config --global advice.detachedHead false
	git config --global init.defaultBranch "master"

	# Locate the temporary folder, avoid double-slash.
	BASH_IT="${BATS_FILE_TMPDIR//\/\///}/.bash_it"

	# This sets up a local test fixture, i.e. a completely fresh and isolated Bash-it directory. This is done to avoid messing with your own Bash-it source directory.
	git --git-dir="${MAIN_BASH_IT_GITDIR?}" worktree add --detach "${BASH_IT}"

	load "${BASH_IT?}/vendor/github.com/erichs/composure/composure.sh"
	# support 'plumbing' metadata
	cite _about _param _example _group _author _version
	cite about-alias about-plugin about-completion

	# Run any local test setup
	local_setup_file
	set +a # not needed, but symetiric!
}

# Load standard _Bash It_ libraries
function setup_libs() {
	local lib
	# Use a loop to allow convenient short-circuiting for some test files
	for lib in "log" "utilities" "helpers" "search" "colors" "preview" "preexec" "history" "command_duration"; do
		load "${BASH_IT?}/lib/${lib}.bash" || return
		# shellcheck disable=SC2015 # short-circuit if we've reached the requested library
		[[ "${lib}" == "${1:-}" ]] && return 0 || true
	done
	return 0
}

function local_setup_file() {
	setup_libs "colors" # overridable default
}

function local_setup() {
	true
}

function local_teardown() {
	true
}

function clean_test_fixture() {
	rm -rf "${BASH_IT_CONFIG?}/enabled"
	rm -rf "${BASH_IT_CONFIG?}/aliases/enabled"
	rm -rf "${BASH_IT_CONFIG?}/completion/enabled"
	rm -rf "${BASH_IT_CONFIG?}/plugins/enabled"

	rm -rf "${BASH_IT_CONFIG?}/tmp/cache"
	rm -rf "${BASH_IT_CONFIG?}/profiles"/test*.bash_it
}

function setup_test_fixture() {
	mkdir -p "${BASH_IT_CONFIG?}/enabled"
	mkdir -p "${BASH_IT_CONFIG?}/aliases/enabled"
	mkdir -p "${BASH_IT_CONFIG?}/completion/enabled"
	mkdir -p "${BASH_IT_CONFIG?}/plugins/enabled"
}

function setup() {
	# be independent of git's system configuration
	export GIT_CONFIG_NOSYSTEM
	# Locate the temporary folder:
	BASH_IT_CONFIG="${BASH_IT?}" #"${BATS_TEST_TMPDIR//\/\///}"
	export XDG_CACHE_HOME="${BATS_TEST_TMPDIR?}"

	setup_test_fixture
	local_setup
}

function teardown() {
	unset GIT_CONFIG_NOSYSTEM
	local_teardown
	clean_test_fixture
}

function teardown_file() {
	# This only serves to clean metadata from the real git repo.
	git --git-dir="${MAIN_BASH_IT_GITDIR?}" worktree remove -f "${BASH_IT?}"
}
